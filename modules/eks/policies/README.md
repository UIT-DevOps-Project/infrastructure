# Download IAM Policy cho AWS Load Balancer Controller

File `aws-lb-controller-policy.json` cần được download thủ công trước khi chạy terraform:

```bash
curl -o aws-lb-controller-policy.json \
  https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
```
