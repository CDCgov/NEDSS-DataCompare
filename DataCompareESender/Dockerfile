# Stage 1: Build the application
FROM amazoncorretto:21 as builder

# Set up the project directory
WORKDIR /usr/src/datacompareesender

# Copy project configuration files
COPY gradle gradle
COPY gradlew .
COPY build.gradle .
COPY settings.gradle .

# Copy source files
COPY DataCompareESender DataCompareESender

# Build the application
RUN ./gradlew :DataCompareESender:buildNeeded -x test --no-daemon

# Stage 2: Create the runtime image
FROM amazoncorretto:21

# Copy the built JAR file from the builder stage
COPY --from=builder /usr/src/datacompareesender/DataCompareESender/build/libs/DataCompareESender*.jar /data-compare-email-service.jar

# Run the application
ENTRYPOINT ["java", "-Xms256m", "-Xmx2048m", "-jar", "/data-compare-email-service.jar"]
