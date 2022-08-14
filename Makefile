.PHONY: run stop destroy install_kind create_image_registry \
		install_kubectl create_cluster connect_registry_to_kind_network \
		connect_registry_to_kind create_kind_cluster_with_registry \
		delete_image_registry delete_kind_cluster \
		delete_kind_cluster_with_registry install_app

imageName = my_first_project_image
imageTag = v1
containerName = my_first_project_container
hostPort = 5050
clusterName = myfirstcluster
appName = myfirstproject

run:
	sudo docker build -t $(imageName):$(imageTag) . && \
		sudo docker run -d --rm --name $(containerName) -p $(hostPort):80 $(imageName):$(imageTag)
		
stop:
	sudo docker container rm -f $(containerName)

destroy: stop
	sudo docker image rm -f $(imageName):$(imageTag)


create_image_registry:
	if sudo docker ps | grep -q 'local-registry'; \
	then echo "---> local resgistry already exists, skipping "; \
	else sudo docker run -d --name local-registry --restart=always -p 5000:5000 registry:2; \
	fi

delete_image_registry:
	if sudo docker ps | grep -q 'local-registry'; \
	then sudo docker container rm -f local-registry; \
	else echo "---> local resgistry doesn't exist, skipping "; \
	fi

push_image_to_local_registry:
	sudo docker tag $(imageName):$(imageTag) localhost:5000/$(imageName):$(imageTag) && \
	sudo docker push localhost:5000/$(imageName):$(imageTag)

create_kind_cluster: create_image_registry
	sudo kind create cluster --name $(clusterName) --config ./cluster/kind_config.yaml || true && \
		sudo kubectl get nodes

delete_kind_cluster:
	if sudo kind get clusters | grep -q $(clusterName); \
	then sudo kind delete cluster --name $(clusterName) ; \
	else echo "---> Cluster doesn't exist, skipping "; \
	fi

connect_registry_to_kind_network:
	sudo docker network connect kind local-registry || true

connect_registry_to_kind: connect_registry_to_kind_network
	sudo kubectl apply -f ./cluster/kind_configmap.yaml

create_kind_cluster_with_registry:
	$(MAKE) create_kind_cluster && $(MAKE) connect_registry_to_kind

delete_kind_cluster_with_registry:
	$(MAKE) delete_kind_cluster && $(MAKE) delete_image_registry

install_app:
	sudo helm upgrade --atomic --install $(appName) ./cluster/chart
