#include <linux/hashtable.h>
#include <linux/list.h>
#include <linux/types.h>

#include "rxe.h"

extern u32 rctl_qp_limit;
extern u32 rctl_conn_limit;

static spinlock_t qp_cnt_table_lock;
struct qp_cnt_node {
        pid_t 			pid;
        u32 			cnt;
        struct hlist_node 	node;
};

static spinlock_t conn_cnt_table_lock;
struct conn_cnt_node {
        __be32 			dst_ip;
        u32 			cnt;
        struct list_head 	qp_list;
        struct hlist_node 	node;
};

DECLARE_HASHTABLE(qp_cnt_table, 5);
DECLARE_HASHTABLE(conn_cnt_table, 5);

/*
static void print_qp_cnt_table(void)
{
        struct qp_cnt_node *obj;
        unsigned bkt;

        pr_info("===== QP Count =====\n");
        hash_for_each(qp_cnt_table, bkt, obj, node) {
                pr_info("+-- pid = %i, count = %u\n",
                        obj->pid, obj->cnt);
        }
}
*/

int rxe_rctl_qp_cnt_inc(struct rxe_qp *qp)
{
	struct qp_cnt_node *obj;
	pid_t pid = qp->pid;
	unsigned long flags;

	spin_lock_irqsave(&qp_cnt_table_lock, flags);

	hash_for_each_possible(qp_cnt_table, obj, node, pid) {
		if (obj->pid != pid)
			continue;

		if (obj->cnt >= rctl_qp_limit) {
			spin_unlock_irqrestore(&qp_cnt_table_lock, flags);
			return -1;
		}
		
		obj->cnt ++;

		spin_unlock_irqrestore(&qp_cnt_table_lock, flags);
		return obj->cnt;
	}

	if (!obj) {
		obj = kmalloc(sizeof(struct qp_cnt_node), GFP_KERNEL);
		obj->pid = pid;
		obj->cnt = 1;
		hash_add(qp_cnt_table, &obj->node, pid);
	}

	spin_unlock_irqrestore(&qp_cnt_table_lock, flags);
	return obj->cnt;
}

int rxe_rctl_qp_cnt_dec(struct rxe_qp *qp)
{
	struct qp_cnt_node *obj;
	pid_t pid = qp->pid;
	unsigned long flags;

	spin_lock_irqsave(&qp_cnt_table_lock, flags);

	hash_for_each_possible(qp_cnt_table, obj, node, pid) {
		if (obj->pid != pid)
			continue;

		if (obj->cnt > 1) {
			obj->cnt--;

			spin_unlock_irqrestore(&qp_cnt_table_lock, flags);
			return obj->cnt;
		} 

		hash_del(&obj->node);
		kfree(obj);

		spin_unlock_irqrestore(&qp_cnt_table_lock, flags);
		return 0;
	}

	spin_unlock_irqrestore(&qp_cnt_table_lock, flags);
	return -1;
}

/*
static void print_conn_cnt_table(void)
{
        struct conn_cnt_node *obj;
	struct list_head *iter;
        struct rxe_qp *qp;
        unsigned bkt;

        pr_info("===== Connetion Count =====\n");
        hash_for_each(conn_cnt_table, bkt, obj, node) {
                pr_info("+-- Dst IP = %pI4, count = %u\n",
                        &obj->dst_ip, obj->cnt);
				
		list_for_each(iter, &obj->qp_list) {
			qp = list_entry(iter, struct rxe_qp, conn_cnt_node);
			pr_info("    +-- [0x%x]\n", qp->ibqp.qp_num);
		}
        }
}
*/

static __be32 *av_dst_ip(struct rxe_av *av)
{
	return &av->dgid_addr._sockaddr_in.sin_addr.s_addr;
}

int rxe_rctl_conn_cnt_inc(struct rxe_qp *qp)
{
	struct conn_cnt_node *obj;
	__be32 dst_ip = *(av_dst_ip(&qp->pri_av));
	unsigned long flags;

	spin_lock_irqsave(&conn_cnt_table_lock, flags);

	hash_for_each_possible(conn_cnt_table, obj, node, dst_ip) {
		if (obj->dst_ip != dst_ip)
			continue;

		if (obj->cnt < rctl_conn_limit) {
			list_add(&qp->conn_cnt_node, &obj->qp_list);
			obj->cnt++;
		
			spin_unlock_irqrestore(&conn_cnt_table_lock, flags);
			return obj->cnt;
		} 

		spin_unlock_irqrestore(&conn_cnt_table_lock, flags);
		return -1;
	}

	if (!obj) {
		obj = kmalloc(sizeof(struct conn_cnt_node), GFP_KERNEL);
		obj->dst_ip = dst_ip;
		obj->cnt = 1;
		INIT_LIST_HEAD(&obj->qp_list);
		list_add(&qp->conn_cnt_node, &obj->qp_list);

		hash_add(conn_cnt_table, &obj->node, dst_ip);
	}

	spin_unlock_irqrestore(&conn_cnt_table_lock, flags);
	return obj->cnt;
}

int rxe_rctl_conn_cnt_dec(struct rxe_qp *qp)
{
	struct conn_cnt_node *obj;
	struct rxe_qp *table_qp;
	struct list_head *iter;
	__be32 dst_ip = *(av_dst_ip(&qp->pri_av));
	unsigned long flags;

	spin_lock_irqsave(&conn_cnt_table_lock, flags);

	hash_for_each_possible(conn_cnt_table, obj, node, dst_ip) {
		if (obj->dst_ip != dst_ip)
			continue;

		list_for_each(iter, &obj->qp_list) {
			table_qp = list_entry(iter, struct rxe_qp, conn_cnt_node);
			if (table_qp != qp)
				continue;
			
			list_del(iter);
			obj->cnt--;

			break;
		}

		if (list_empty(&obj->qp_list)) {
			hash_del(&obj->node);
			kfree(obj);
		}

		spin_unlock_irqrestore(&conn_cnt_table_lock, flags);
		return obj->cnt;
	}

	spin_unlock_irqrestore(&conn_cnt_table_lock, flags);
	return -1;
}

void rxe_rctl_init(void)
{
	spin_lock_init(&qp_cnt_table_lock);
	spin_lock_init(&conn_cnt_table_lock);
}
