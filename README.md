# custom-builder

## Setup
Start openshift cluster and login as admin
```
oc cluster up
oc login -u system:admin
```

Grant *system:build-strategy-custom* to *developer*
```
oc adm policy add-role-to-user system:build-strategy-custom developer
```

Deploy buildconfig and imagestreams for [baseimages](https://github.com/tjololo/custom-build-images) and custom builder
```
oc create -f https://raw.githubusercontent.com/tjololo/custom-builder/master/custom-builder-base-images-template.json 
```

Create template for create builds that uses custom-builder
```
oc create -f https://raw.githubusercontent.com/tjololo/custom-builder/master/custom-builder-build-template.json
```

Cleanup
```
oc delete all -l group=custom-builder
```