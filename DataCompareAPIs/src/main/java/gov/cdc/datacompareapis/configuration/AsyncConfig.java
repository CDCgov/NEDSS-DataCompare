package gov.cdc.datacompareapis.configuration;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;

@Configuration
@EnableAsync
public class AsyncConfig {

    @Value("${app.async.core-pool-size:8}")
    private int corePoolSize;

    @Value("${app.async.max-pool-size:16}")
    private int maxPoolSize;

    @Value("${app.async.queue-capacity:50}")
    private int queueCapacity;

    @Value("${app.async.chunk-core-pool-size:4}")
    private int chunkCorePoolSize;

    @Value("${app.async.chunk-max-pool-size:8}")
    private int chunkMaxPoolSize;

    @Value("${app.async.chunk-queue-capacity:50}")
    private int chunkQueueCapacity;

    @Bean(name = "pullerTaskExecutor")
    public Executor pullerTaskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(corePoolSize);
        executor.setMaxPoolSize(maxPoolSize);
        executor.setQueueCapacity(queueCapacity);
        executor.setThreadNamePrefix("DataPuller-");
        executor.initialize();
        return executor;
    }

    @Bean(name = "chunkTaskExecutor")
    public Executor chunkTaskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(chunkCorePoolSize);
        executor.setMaxPoolSize(chunkMaxPoolSize);
        executor.setQueueCapacity(chunkQueueCapacity);
        executor.setThreadNamePrefix("ChunkProcessor-");
        executor.initialize();
        return executor;
    }
}