#include <linux/hashtable.h>
#include <linux/types.h>

#include "rxe.h"

struct h_node {
        u32 vqpn;
        int index;
        struct hlist_node node;
};

static spinlock_t htable_lock;
DECLARE_HASHTABLE(htable, 10);

static u32 get_vqpn(void)
{
        u32 rand;
        get_random_bytes(&rand, sizeof(rand));
        return rand & (0x00ffffff);
}

/*
static void print_htable(void)
{
        struct h_node *obj;
        unsigned bkt;

        pr_info("==START=============================\n");
        hash_for_each(htable, bkt, obj, node) {
                pr_info("myhashtable: element: vqpn = %u, index = %d\n",
                        obj->vqpn, obj->index);
        }
        pr_info("==END===============================\n");
}
*/

u32 rxe_vqpn_add(int index)
{
        struct h_node *ptr = kmalloc(sizeof(struct h_node), GFP_KERNEL);
        u32 vqpn = get_vqpn();
	unsigned long flags;

	spin_lock_irqsave(&htable_lock, flags);

        // print_htable();
        ptr->vqpn = vqpn;
        ptr->index = index;
        hash_add(htable, &ptr->node, vqpn);
        // print_htable();

	spin_unlock_irqrestore(&htable_lock, flags);
        return vqpn;
}

int rxe_vqpn_to_index(u32 vqpn)
{
        struct h_node *obj;
        hash_for_each_possible(htable, obj, node, vqpn) {
                if(obj->vqpn == vqpn) {
                        return obj->index;
                }
        }
        return -1;
}

void rxe_vqpn_remove(u32 vqpn)
{
        struct h_node *obj;

        // print_htable();
        hash_for_each_possible(htable, obj, node, vqpn) {
                if(obj->vqpn == vqpn) {
                        hash_del(&obj->node);
                        break;
                }
        }
        if (obj) kfree(obj);
        // print_htable();
}


void rxe_vqpn_init(void) 
{
	spin_lock_init(&htable_lock);
}