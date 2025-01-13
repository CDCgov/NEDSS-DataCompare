# Stage 1: Build the application
FROM amazoncorretto:21 as builder
RUN yum install -y aws-cli
# Set up the project directory
WORKDIR /usr/src/datacompareapi

# Copy project configuration files
COPY gradle gradle
COPY gradlew .
COPY build.gradle .
COPY settings.gradle .

# Copy source files
COPY DataCompareAPIs DataCompareAPIs

# Build the application
RUN ./gradlew :DataCompareAPIs:buildNeeded -x test --no-daemon

# Stage 2: Create the runtime image
FROM amazoncorretto:21

# Copy the built JAR file from the builder stage
COPY --from=builder /usr/src/datacompareapi/DataCompareAPIs/build/libs/DataCompareAPIs*.jar /data-compare-api-service.jar

# Run the application
ENTRYPOINT ["java", "-Xms256m", "-Xmx2048m", "-jar", "/data-compare-api-service.jar"]
