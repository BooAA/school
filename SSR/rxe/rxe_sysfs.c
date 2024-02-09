// SPDX-License-Identifier: GPL-2.0 OR Linux-OpenIB
/*
 * Copyright (c) 2016 Mellanox Technologies Ltd. All rights reserved.
 * Copyright (c) 2015 System Fabric Works, Inc. All rights reserved.
 */

#include "rxe.h"
#include "rxe_net.h"

u8 mac_key_kobj[RXE_MAC_KEY_SIZE];
u32 rctl_qp_limit = 32;
u32 rctl_conn_limit = 32;

/* Copy argument and remove trailing CR. Return the new length. */
static int sanitize_arg(const char *val, char *intf, int intf_len)
{
	int len;

	if (!val)
		return 0;

	/* Remove newline. */
	for (len = 0; len < intf_len - 1 && val[len] && val[len] != '\n'; len++)
		intf[len] = val[len];
	intf[len] = 0;

	if (len == 0 || (val[len] != 0 && val[len] != '\n'))
		return 0;

	return len;
}

static int rxe_param_set_add(const char *val, const struct kernel_param *kp)
{
	int len;
	int err = 0;
	char intf[32];
	struct net_device *ndev;
	struct rxe_dev *exists;

	if (!rxe_initialized) {
		pr_err("Module parameters are not supported, use rdma link add or rxe_cfg\n");
		return -EAGAIN;
	}

	len = sanitize_arg(val, intf, sizeof(intf));
	if (!len) {
		pr_err("add: invalid interface name\n");
		return -EINVAL;
	}

	ndev = dev_get_by_name(&init_net, intf);
	if (!ndev) {
		pr_err("interface %s not found\n", intf);
		return -EINVAL;
	}

	if (is_vlan_dev(ndev)) {
		pr_err("rxe creation allowed on top of a real device only\n");
		err = -EPERM;
		goto err;
	}

	exists = rxe_get_dev_from_net(ndev);
	if (exists) {
		ib_device_put(&exists->ib_dev);
		pr_err("already configured on %s\n", intf);
		err = -EINVAL;
		goto err;
	}

	err = rxe_net_add("rxe%d", ndev);
	if (err) {
		pr_err("failed to add %s\n", intf);
		goto err;
	}

err:
	dev_put(ndev);
	return err;
}

static int rxe_param_set_remove(const char *val, const struct kernel_param *kp)
{
	int len;
	char intf[32];
	struct ib_device *ib_dev;

	len = sanitize_arg(val, intf, sizeof(intf));
	if (!len) {
		pr_err("add: invalid interface name\n");
		return -EINVAL;
	}

	if (strncmp("all", intf, len) == 0) {
		pr_info("rxe_sys: remove all");
		ib_unregister_driver(RDMA_DRIVER_RXE);
		return 0;
	}

	ib_dev = ib_device_get_by_name(intf, RDMA_DRIVER_RXE);
	if (!ib_dev) {
		pr_err("not configured on %s\n", intf);
		return -EINVAL;
	}

	ib_unregister_device_and_put(ib_dev);

	return 0;
}

static int rxe_param_set_mac_key(const char *val, const struct kernel_param *kp)
{
	memcpy(mac_key_kobj, val, RXE_MAC_KEY_SIZE);
        return 0;
}

static int rxe_param_set_qp_limit(const char *val, const struct kernel_param *kp)
{
	return kstrtouint(val, 10, &rctl_qp_limit);
};

static int rxe_param_set_conn_limit(const char *val, const struct kernel_param *kp)
{
	return kstrtouint(val, 10, &rctl_conn_limit);
};

static inline struct rxe_qp *to_rxe_qp(struct kobject *kobj)
{
	return container_of(kobj, struct rxe_qp, kobj);
}

struct rxe_qp_attribute {
	struct attribute attr;
	ssize_t (*show)(struct rxe_qp *qp, struct rxe_qp_attribute *attr,
                        char *buf);
	ssize_t (*store)(struct rxe_qp *qp, struct rxe_qp_attribute *attr,
                         const char *buf, size_t count);
};

static inline struct rxe_qp_attribute *to_rxe_qp_attr(struct attribute *attr)
{
	return container_of(attr, struct rxe_qp_attribute, attr);
}

static ssize_t rxe_qp_attr_show(struct kobject *kobj,
                                struct attribute *attr,
                                char *buf)
{
	struct rxe_qp_attribute *attribute;
	struct rxe_qp *qp;

	attribute = to_rxe_qp_attr(attr);
	qp = to_rxe_qp(kobj);

	if (!attribute->show)
		return -EIO;

	return attribute->show(qp, attribute, buf);
}

static ssize_t rxe_qp_attr_store(struct kobject *kobj,
                                 struct attribute *attr,
                                 const char *buf, size_t len)
{
	struct rxe_qp_attribute *attribute;
	struct rxe_qp *qp;

	attribute = to_rxe_qp_attr(attr);
	qp = to_rxe_qp(kobj);

	if (!attribute->store)
		return -EIO;

	return attribute->store(qp, attribute, buf, len);
}

static const struct sysfs_ops rxe_qp_sysfs_ops = {
	.show = rxe_qp_attr_show,
	.store = rxe_qp_attr_store,
};

static void rxe_qp_release(struct kobject *kobj)
{
        pr_info("release qp!");
}

static ssize_t send_pkts_show(struct rxe_qp *qp,
                              struct rxe_qp_attribute *attr,
                              char *buf)
{
	return sprintf(buf, "%llu\n", qp->stats_counters[RXE_CNT_SENT_PKTS]);
}

static ssize_t send_pkts_store(struct rxe_qp *qp,
                               struct rxe_qp_attribute *attr,
                               const char *buf, size_t count)
{
	sscanf(buf, "%llu", &qp->stats_counters[RXE_CNT_SENT_PKTS]);
	return count;
}

static struct rxe_qp_attribute send_pkts_attribute =
	__ATTR(send_pkts, 0664, send_pkts_show, send_pkts_store);

static ssize_t rcvd_pkts_show(struct rxe_qp *qp,
                              struct rxe_qp_attribute *attr,
                              char *buf)
{
	return sprintf(buf, "%llu\n", qp->stats_counters[RXE_CNT_RCVD_PKTS]);
}

static ssize_t rcvd_pkts_store(struct rxe_qp *qp,
                               struct rxe_qp_attribute *attr,
                               const char *buf, size_t count)
{
	sscanf(buf, "%llu", &qp->stats_counters[RXE_CNT_RCVD_PKTS]);
	return count;
}

static struct rxe_qp_attribute rcvd_pkts_attribute =
	__ATTR(rcvd_pkts, 0664, rcvd_pkts_show, rcvd_pkts_store);

static ssize_t dup_req_show(struct rxe_qp *qp,
                            struct rxe_qp_attribute *attr,
                            char *buf)
{
	return sprintf(buf, "%llu\n", qp->stats_counters[RXE_CNT_DUP_REQ]);
}

static ssize_t dup_req_store(struct rxe_qp *qp,
                             struct rxe_qp_attribute *attr,
                             const char *buf, size_t count)
{
	sscanf(buf, "%llu", &qp->stats_counters[RXE_CNT_DUP_REQ]);
	return count;
}

static struct rxe_qp_attribute dup_req_attribute =
	__ATTR(dup_req, 0664, dup_req_show, dup_req_store);

static ssize_t out_of_seq_req_show(struct rxe_qp *qp,
                                   struct rxe_qp_attribute *attr,
                                   char *buf)
{
	return sprintf(buf, "%llu\n",
                       qp->stats_counters[RXE_CNT_OUT_OF_SEQ_REQ]);
}

static ssize_t out_of_seq_req_store(struct rxe_qp *qp,
                                    struct rxe_qp_attribute *attr,
                                    const char *buf, size_t count)
{
	sscanf(buf, "%llu", &qp->stats_counters[RXE_CNT_OUT_OF_SEQ_REQ]);
	return count;
}

static struct rxe_qp_attribute out_of_seq_req_attribute =
	__ATTR(out_of_seq_req, 0664, out_of_seq_req_show, out_of_seq_req_store);

static ssize_t rcv_rnr_show(struct rxe_qp *qp,
                            struct rxe_qp_attribute *attr,
                            char *buf)
{
	return sprintf(buf, "%llu\n", qp->stats_counters[RXE_CNT_RCV_RNR]);
}

static ssize_t rcv_rnr_store(struct rxe_qp *qp,
                             struct rxe_qp_attribute *attr,
                             const char *buf, size_t count)
{
	sscanf(buf, "%llu", &qp->stats_counters[RXE_CNT_RCV_RNR]);
	return count;
}

static struct rxe_qp_attribute rcv_rnr_attribute =
	__ATTR(rcv_rnr, 0664, rcv_rnr_show, rcv_rnr_store);

static ssize_t snd_rnr_show(struct rxe_qp *qp,
                            struct rxe_qp_attribute *attr,
                            char *buf)
{
	return sprintf(buf, "%llu\n", qp->stats_counters[RXE_CNT_SND_RNR]);
}

static ssize_t snd_rnr_store(struct rxe_qp *qp,
                             struct rxe_qp_attribute *attr,
                             const char *buf, size_t count)
{
	sscanf(buf, "%llu", &qp->stats_counters[RXE_CNT_SND_RNR]);
	return count;
}

static struct rxe_qp_attribute snd_rnr_attribute =
	__ATTR(snd_rnr, 0664, snd_rnr_show, snd_rnr_store);

static ssize_t rcv_seq_err_show(struct rxe_qp *qp,
                                struct rxe_qp_attribute *attr,
                                char *buf)
{
	return sprintf(buf, "%llu\n", qp->stats_counters[RXE_CNT_RCV_SEQ_ERR]);
}

static ssize_t rcv_seq_err_store(struct rxe_qp *qp,
                                 struct rxe_qp_attribute *attr,
                                 const char *buf, size_t count)
{
	sscanf(buf, "%llu", &qp->stats_counters[RXE_CNT_RCV_SEQ_ERR]);
	return count;
}

static struct rxe_qp_attribute rcv_seq_err_attribute =
	__ATTR(rcv_seq_err, 0664, rcv_seq_err_show, rcv_seq_err_store);

static ssize_t retry_exceeded_show(struct rxe_qp *qp,
                                   struct rxe_qp_attribute *attr,
                                   char *buf)
{
	return sprintf(buf, "%llu\n",
                       qp->stats_counters[RXE_CNT_RETRY_EXCEEDED]);
}

static ssize_t retry_exceeded_store(struct rxe_qp *qp,
                                    struct rxe_qp_attribute *attr,
                                    const char *buf, size_t count)
{
	sscanf(buf, "%llu", &qp->stats_counters[RXE_CNT_RETRY_EXCEEDED]);
	return count;
}

static struct rxe_qp_attribute retry_exceeded_attribute =
	__ATTR(retry_exceeded, 0664,
               retry_exceeded_show, retry_exceeded_store);

static ssize_t rnr_retry_exceeded_show(struct rxe_qp *qp,
                                   struct rxe_qp_attribute *attr,
                                   char *buf)
{
	return sprintf(buf, "%llu\n",
                       qp->stats_counters[RXE_CNT_RNR_RETRY_EXCEEDED]);
}

static ssize_t rnr_retry_exceeded_store(struct rxe_qp *qp,
                                    struct rxe_qp_attribute *attr,
                                    const char *buf, size_t count)
{
	sscanf(buf, "%llu", &qp->stats_counters[RXE_CNT_RNR_RETRY_EXCEEDED]);
	return count;
}

static struct rxe_qp_attribute rnr_retry_exceeded_attribute =
	__ATTR(rnr_retry_exceeded, 0664,
               rnr_retry_exceeded_show, rnr_retry_exceeded_store);

static ssize_t comp_retry_show(struct rxe_qp *qp,
                                   struct rxe_qp_attribute *attr,
                                   char *buf)
{
	return sprintf(buf, "%llu\n",
                       qp->stats_counters[RXE_CNT_COMP_RETRY]);
}

static ssize_t comp_retry_store(struct rxe_qp *qp,
                                    struct rxe_qp_attribute *attr,
                                    const char *buf, size_t count)
{
	sscanf(buf, "%llu", &qp->stats_counters[RXE_CNT_COMP_RETRY]);
	return count;
}

static struct rxe_qp_attribute comp_retry_attribute =
	__ATTR(comp_retry, 0664, comp_retry_show, comp_retry_store);

static ssize_t send_err_show(struct rxe_qp *qp,
                                   struct rxe_qp_attribute *attr,
                                   char *buf)
{
	return sprintf(buf, "%llu\n",
                       qp->stats_counters[RXE_CNT_SEND_ERR]);
}

static ssize_t send_err_store(struct rxe_qp *qp,
                                    struct rxe_qp_attribute *attr,
                                    const char *buf, size_t count)
{
	sscanf(buf, "%llu", &qp->stats_counters[RXE_CNT_SEND_ERR]);
	return count;
}

static struct rxe_qp_attribute send_err_attribute =
	__ATTR(send_err, 0664, send_err_show, send_err_store);

static ssize_t rdma_send_show(struct rxe_qp *qp,
                                   struct rxe_qp_attribute *attr,
                                   char *buf)
{
	return sprintf(buf, "%llu\n", qp->stats_counters[RXE_CNT_RDMA_SEND]);
}

static ssize_t rdma_send_store(struct rxe_qp *qp,
                                    struct rxe_qp_attribute *attr,
                                    const char *buf, size_t count)
{
	sscanf(buf, "%llu", &qp->stats_counters[RXE_CNT_RDMA_SEND]);
	return count;
}

static struct rxe_qp_attribute rdma_send_attribute =
	__ATTR(rdma_send, 0664, rdma_send_show, rdma_send_store);

static ssize_t rdma_recv_show(struct rxe_qp *qp,
                                   struct rxe_qp_attribute *attr,
                                   char *buf)
{
	return sprintf(buf, "%llu\n", qp->stats_counters[RXE_CNT_RDMA_RECV]);
}

static ssize_t rdma_recv_store(struct rxe_qp *qp,
                                    struct rxe_qp_attribute *attr,
                                    const char *buf, size_t count)
{
	sscanf(buf, "%llu", &qp->stats_counters[RXE_CNT_RDMA_RECV]);
	return count;
}

static struct rxe_qp_attribute rdma_recv_attribute =
	__ATTR(rdma_recv, 0664, rdma_recv_show, rdma_recv_store);

static struct attribute *rxe_qp_default_attrs[] = {
	&send_pkts_attribute.attr,
        &rcvd_pkts_attribute.attr,
        &dup_req_attribute.attr,
        &out_of_seq_req_attribute.attr,
        &rcv_rnr_attribute.attr,
        &snd_rnr_attribute.attr,
        &rcv_seq_err_attribute.attr,
        &retry_exceeded_attribute.attr,
        &rnr_retry_exceeded_attribute.attr,
        &comp_retry_attribute.attr,
        &send_err_attribute.attr,
        &rdma_send_attribute.attr,
        &rdma_recv_attribute.attr,
	NULL,	/* need to NULL terminate the list of attributes */
};

static struct kobj_type rxe_qp_ktype = {
        .sysfs_ops = &rxe_qp_sysfs_ops,
        .release = rxe_qp_release,
        .default_attrs = rxe_qp_default_attrs,
};

static struct kset *rdma_rxe_kset;

int rxe_create_qp_kset(void)
{
        rdma_rxe_kset = kset_create_and_add("rdma_rxe", NULL, kernel_kobj);
	if (!rdma_rxe_kset)
		return -ENOMEM;
        return 0;
}

void rxe_destroy_qp_kset(void)
{
        kset_unregister(rdma_rxe_kset);
}

int rxe_create_qp_kobj(struct rxe_qp *qp, u32 vqpn)
{
        int err;
        char name[16];

        qp->kobj.kset = rdma_rxe_kset;
        
        snprintf(name, sizeof(name), "%u", vqpn);
        err = kobject_init_and_add(&qp->kobj, &rxe_qp_ktype, NULL, "%s", name);
        if (err) {
                kobject_put(&qp->kobj);
                return err;
        }
        
        kobject_uevent(&qp->kobj, KOBJ_ADD);
        return 0;
}

void rxe_destroy_qp_kobj(struct rxe_qp *qp)
{
        kobject_put(&qp->kobj);
}

static const struct kernel_param_ops rxe_add_ops = {
	.set = rxe_param_set_add,
};

static const struct kernel_param_ops rxe_remove_ops = {
	.set = rxe_param_set_remove,
};

static const struct kernel_param_ops rxe_mac_ops = {
	.set = rxe_param_set_mac_key,
};

static const struct kernel_param_ops rxe_qp_limit_ops = {
	.set = rxe_param_set_qp_limit,
};

static const struct kernel_param_ops rxe_conn_limit_ops = {
	.set = rxe_param_set_conn_limit,
};

module_param_cb(add, &rxe_add_ops, NULL, 0200);
MODULE_PARM_DESC(add, "DEPRECATED.  Create RXE device over network interface");
module_param_cb(remove, &rxe_remove_ops, NULL, 0200);
MODULE_PARM_DESC(remove, "DEPRECATED.  Remove RXE device over network interface");
module_param_cb(mac_key, &rxe_mac_ops, NULL, 0200);
MODULE_PARM_DESC(mac_key, "Setup private key for secure MAC transformation");
module_param_cb(qp_limit, &rxe_qp_limit_ops, NULL, 0200);
MODULE_PARM_DESC(qp_limit, "Setup limit of qp number per process");	
module_param_cb(conn_limit, &rxe_conn_limit_ops, NULL, 0200);
MODULE_PARM_DESC(conn_limit, "Setup limit of qp connection number per ip");	
