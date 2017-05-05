#!/bin/ash
echo ""
echo "===Printing Variables==="
echo "BUILD: ${BUILD}"
echo "SOURCE_REPOSITORY: ${SOURCE_REPOSITORY}"
echo "SOURCE_URI: ${SOURCE_URI}"
echo "SOURCE_CONTEXT_DIR: ${SOURCE_CONTEXTDIR}"
echo "SOURCE_REF: ${SOURCE_REF}"
echo "ORIGIN_VERSION: ${ORIGIN_VERSION}"
echo "OUTPUT_REGISTRY: ${OUTPUT_REGISTRY}"
echo "OUTPUT_IMAGE: ${OUTPUT_IMAGE}"
echo "PUSH_DOCKERCFG_PATH: ${PUSH_DOCKERCFG_PATH}"
echo "DOCKER_SOCKET ${DOCKER_SOCKET}"
echo "BUILDER_STRATEGY ${BUILDER_STRATEGY}"
echo "BASE_IMAGE_PROJECT ${BASE_IMAGE_PROJECT}"
echo "===End Variables==="
echo ""



#Running the actual build and push
echo "Fetching custom buildstrategies"
STRATEGY_FOLDER=$(mktemp -d)
git clone --recursive "https://github.com/tjololo/custom-build-strategies.git" ${STRATEGY_FOLDER}
if [ $? != 0 ]; then
	echo "Error trying to fetch custom buildstrategies"
	exit 1
fi

echo "Settingup environment"
source /tmp/parse_yaml.sh
source /tmp/value_of.sh
DOCKER_SOURCE_DIR=$(mktemp -d)
if [ -n "${OUTPUT_IMAGE}" ]; then
  TAG="${OUTPUT_REGISTRY}/${OUTPUT_IMAGE}"
fi

#Execute strategy
echo "Executing custom buildstrategy: ${BUILDER_STRATEGY}"
cd $STRATEGY_FOLDER
eval $(parse_yaml inventory.yml "config_")
strategy_key="config_strategy_${BUILDER_STRATEGY}_script"
strategy_image_key="config_strategy_${BUILDER_STRATEGY}_image"
base_image_name=$(value_of $strategy_image_key)
strategy=$(value_of $strategy_key)
if [ -z "$strategy" ]; then
        echo "Strategy $1 not found in inventoryfile"
        exit 1
fi
if [ ! -e "$strategy" ]; then
        echo "File ($strategy) defined in strategy $1 not found"
        exit 1
fi
source $strategy
if [ $? != 0 ]; then
	echo "Error occured during execution of build strategy ${BUILDER_STRATEGY}"
	exit 1
fi

#Execute docker build and push
echo "Gathering build facts"
IMAGELABELS="--label net.tjololo.strategy.name=\"${BUILD_STRATEGY}\"
 --label net.tjololo.strategy.source.ref=\"${STRATEGY_SOURCE_REF}\"
 --label net.tjololo.strategy.source.repo=\"${STRATEGY_FOLDER}\""
echo "Setting up complete Dockerfile from Docker.part"
echo "FROM ${OUTPUT_REGISTRY}/${BASE_IMAGE_PROJECT}/${base_image_name}" > ${DOCKER_SOURCE_DIR}/Dockerfile
cat ${DOCKER_SOURCE_DIR}/Dockerfile.part >> ${DOCKER_SOURCE_DIR}/Dockerfile
echo "Printing dockerfile"
cat ${DOCKER_SOURCE_DIR}/Dockerfile
echo "Starting docker build"
docker build --rm ${IMAGELABELS} -t ${TAG} ${DOCKER_SOURCE_DIR}
if [ $? != 0 ]; then
	echo "Error during build of docker image. Please check custom strategy $strategy"
	exit 1
fi
if [[ -d /var/run/secrets/openshift.io/push ]] && [[ ! -e /root/.dockercfg ]]; then
  cp /var/run/secrets/openshift.io/push/.dockercfg /root/.dockercfg
fi

if [ -n "${OUTPUT_IMAGE}" ] || [ -s "/root/.dockercfg" ]; then
  docker push "${TAG}"
fi
echo "builder done"
