# Monitoring ports (Grafana, Prometheus, Alertmanager)
resource "aws_security_group_rule" "monitoring_grafana" {
  type              = "ingress"
  from_port         = 3001
  to_port           = 3001
  protocol          = "tcp"
  cidr_blocks       = [var.your_ip]
  security_group_id = aws_security_group.ec2.id
  description       = "Grafana access from your IP"
}

resource "aws_security_group_rule" "monitoring_prometheus" {
  type              = "ingress"
  from_port         = 9090
  to_port           = 9090
  protocol          = "tcp"
  cidr_blocks       = [var.your_ip]
  security_group_id = aws_security_group.ec2.id
  description       = "Prometheus access from your IP"
}

resource "aws_security_group_rule" "monitoring_alertmanager" {
  type              = "ingress"
  from_port         = 9093
  to_port           = 9093
  protocol          = "tcp"
  cidr_blocks       = [var.your_ip]
  security_group_id = aws_security_group.ec2.id
  description       = "Alertmanager access from your IP"
}
