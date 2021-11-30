PROJECT_ID=kenthua-test-standalone

gcloud artifacts repositories create core-build \
    --repository-format=maven \
    --location=us \
    --async

gcloud artifacts print-settings mvn \
    --project=${PROJECT_ID} \
    --repository=core-build \
    --location=us

# https://spring.io/guides/gs/spring-boot/
git clone https://github.com/spring-guides/gs-spring-boot.git
cd gs-spring-boot/complete
# add repo to pom.xml

## local testing
mvn deploy:deploy-file \
-Durl=artifactregistry://us-maven.pkg.dev/kenthua-test-identity/core-build \
-DpomFile=pom.xml -Dfile=target/spring-boot-complete-0.0.1-SNAPSHOT.jar \
-Dmaven.test.skip=true

# get the app to m2
mvn dependency:get \
  -Dartifact=com.example:spring-boot-complete:0.0.1-SNAPSHOT \

# copy locally
mvn dependency:copy \
  -Dartifact=com.example:spring-boot-complete:0.0.1-SNAPSHOT \
  -DoutputDirectory=./

# plugin pom.xml
      <plugin>
        <groupId>com.google.cloud.tools</groupId>
        <artifactId>jib-maven-plugin</artifactId>
        <version>3.1.4</version>
      </plugin>

# containerize
mvn compile jib:build \
  -Dimage=us-docker.pkg.dev/kenthua-test-standalone/core-image/spring-boot-app

# default pool
gcloud builds submit \
  --project ${PROJECT_ID}

# hybrid pool
export CLUSTER_NAME=user1
export PROJECT_ID=kenthua-test-identity
gcloud alpha builds submit \
  --config=cloudbuild-hybrid.yaml \
  --substitutions=_CLUSTER_NAME="${CLUSTER_NAME}" \
  --project ${PROJECT_ID}