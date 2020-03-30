Sequence on the docker images setup
1/ Get current user auth token
2/ docker login 
need to login to the tenancies OCIR as the current user using the auth token
3/ Download the pre-built docker images
docker pull fra.ocir.io/oractdemeabdmnative/h-k8s_repo/storefront:0.0.1
docker pull fra.ocir.io/oractdemeabdmnative/h-k8s_repo/storefront:0.0.2
docker pull fra.ocir.io/oractdemeabdmnative/h-k8s_repo/stockmanager:0.0.1
4/ Change the docker image tags
In the target section :
  change myregion  to be the one for your region, e.g. fra.ocir.io
  change mytenancy to be your tenancy
  change myrepo to be your repo name
  
docker tag fra.ocir.io/oractdemeabdmnative/h-k8s_repo/storefront:0.0.1 myregion/mytenancy/myrepoo/storefront:0.0.1
docker tag fra.ocir.io/oractdemeabdmnative/h-k8s_repo/storefront:0.0.2 myregion/mytenancy/myrepo/storefront:0.0.2
docker tag fra.ocir.io/oractdemeabdmnative/h-k8s_repo/stockmanager:0.0.1 myregion/mytenancy/myrepo/stockmanager:0.0.1

5/ Push the images up to your tenancy
  change myregion  to be the one for your region, e.g. fra.ocir.io
  change mytenancy to be your tenancy
  change myrepo to be your repo name

docker push myregion/mytenancy/myrepoo/storefront:0.0.1
docker push myregion/mytenancy/myrepo/storefront:0.0.2
docker push myregion/mytenancy/myrepo/stockmanager:0.0.1
  