#!/bin/bash

echo "🧹 Cleaning old Jenkins kube and minikube directories..."
sudo rm -rf /var/lib/jenkins/.kube
sudo rm -rf /var/lib/jenkins/.minikube

echo "📂 Copying Minikube and Kube config to Jenkins..."
sudo cp -r /home/ec2-user/.minikube /var/lib/jenkins/
sudo cp -r /home/ec2-user/.kube /var/lib/jenkins/

echo "🔒 Fixing permissions..."
sudo chown -R jenkins:jenkins /var/lib/jenkins/.minikube
sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube

echo "✏️ Updating kubeconfig paths to Jenkins-owned .minikube directory..."
sudo sed -i 's|/home/ec2-user/.minikube|/var/lib/jenkins/.minikube|g' /var/lib/jenkins/.kube/config

echo "✅ Verifying as Jenkins user..."
sudo -u jenkins KUBECONFIG=/var/lib/jenkins/.kube/config kubectl get nodes

