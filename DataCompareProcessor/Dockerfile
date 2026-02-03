# Stage 1: Build the application
FROM amazoncorretto:25 as builder

# Set up the project directory
WORKDIR /usr/src/datacompareprocessor

# Copy project configuration files
COPY gradle gradle
COPY gradlew .
COPY build.gradle .
COPY settings.gradle .

# Copy source files
COPY DataCompareProcessor DataCompareProcessor

# Build the application
RUN ./gradlew :DataCompareProcessor:buildNeeded -x test --no-daemon

# Stage 2: Create the runtime image
FROM amazoncorretto:25

# Copy the built JAR file from the builder stage
COPY --from=builder /usr/src/datacompareprocessor/DataCompareProcessor/build/libs/DataCompareProcessor*.jar /data-compare-processor-service.jar

# Run the application
ENTRYPOINT ["java", "-Xms256m", "-Xmx2048m", "-jar", "/data-compare-processor-service.jar"]
