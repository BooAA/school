#include "rxe.h"

static int init_ctx(struct cipher_ctx *ctx, u8 *key)
{
        int err;
        
        ctx->tfm = crypto_alloc_skcipher("__ctr(aes)", CRYPTO_ALG_INTERNAL, 0);
        if (IS_ERR(ctx->tfm)) {
                pr_err("Error allocating __ctr(aes) handle: %ld\n", PTR_ERR(ctx->tfm));
                return PTR_ERR(ctx->tfm);
        }

        err = crypto_skcipher_setkey(ctx->tfm, key, RXE_CIPHER_KEY_SIZE);
        if (err) {
                pr_err("Error setting key: %d\n", err);
                return err;
        }

	ctx->req = skcipher_request_alloc(ctx->tfm, GFP_KERNEL);
        if (!ctx->req) {
                err = -ENOMEM;
                return err;
        }

        return 0;
}

int rxe_cipher_init_qp_ctx(struct rxe_qp *qp)
{
        int err;

        u8 key[32] = {
                0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,                
                0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,                
                0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,                
                0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07
	};

        err = init_ctx(&qp->req_cipher_ctx, key);
        if (err)
                return err;

        err = init_ctx(&qp->resp_cipher_ctx, key);
        if (err)
                return err;

        err = init_ctx(&qp->resp_ack_cipher_ctx, key);
        if (err)
                return err;

        err = init_ctx(&qp->comp_cipher_ctx, key);
        if (err)
                return err;
        
        return 0;
}

void rxe_cipher_free_qp_ctx(struct rxe_qp *qp)
{
        if (qp->req_cipher_ctx.tfm)
                crypto_free_skcipher(qp->req_cipher_ctx.tfm);
        
        if (qp->resp_cipher_ctx.tfm)
                crypto_free_skcipher(qp->resp_cipher_ctx.tfm);

        if (qp->resp_ack_cipher_ctx.tfm)
                crypto_free_skcipher(qp->resp_ack_cipher_ctx.tfm);

        if (qp->comp_cipher_ctx.tfm)
                crypto_free_skcipher(qp->comp_cipher_ctx.tfm);

        if (qp->req_cipher_ctx.req)
                skcipher_request_free(qp->req_cipher_ctx.req);
        
        if (qp->resp_cipher_ctx.req)
                skcipher_request_free(qp->resp_cipher_ctx.req);
        
        if (qp->resp_ack_cipher_ctx.req)
                skcipher_request_free(qp->resp_ack_cipher_ctx.req);
        
        if (qp->comp_cipher_ctx.req)
                skcipher_request_free(qp->comp_cipher_ctx.req);
}

int rxe_cipher_encrypt(struct cipher_ctx *ctx, u8* data, size_t datasize)
{
	struct skcipher_request *req = ctx->req;
        struct scatterlist sg;
        DECLARE_CRYPTO_WAIT(wait);
        u8 iv[16] = {0};  /* AES-256-XTS takes a 16-byte IV */
        int err;

	if (datasize == 0) 
		return 0;

        sg_init_one(&sg, data, datasize);
        skcipher_request_set_callback(req, 0, crypto_req_done, &wait);
        skcipher_request_set_crypt(req, &sg, &sg, datasize, iv);
        err = crypto_wait_req(crypto_skcipher_encrypt(req), &wait);
        if (err) {
                pr_err("Error encrypting data: %d, Datasize: %lu\n", err, datasize);
                return err;
        }

        pr_debug("Encryption was successful\n");

        return 0;
}

int rxe_cipher_decrypt(struct cipher_ctx *ctx, u8* data, size_t datasize)
{
	struct skcipher_request *req = ctx->req;
        struct scatterlist sg;
        DECLARE_CRYPTO_WAIT(wait);
        u8 iv[16] = {0};  /* AES-256-XTS takes a 16-byte IV */
        int err;

	if (datasize == 0) 
		return 0;

        sg_init_one(&sg, data, datasize);
        skcipher_request_set_callback(req, 0, crypto_req_done, &wait);
        skcipher_request_set_crypt(req, &sg, &sg, datasize, iv);
        err = crypto_wait_req(crypto_skcipher_decrypt(req), &wait);
        if (err) {
                pr_err("Error decrypting data: %d, Datasize: %lu\n", err, datasize);
                return err;
        }

        pr_debug("Decryption was successful\n");

        return 0;
}