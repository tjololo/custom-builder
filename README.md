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

