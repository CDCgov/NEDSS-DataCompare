package gov.cdc.datacompareprocessor.configuration;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;

@Configuration
@EnableAsync
public class AsyncConfig {

    @Value("${app.async.comparison-core-pool-size:4}")
    private int comparisonCorePoolSize;

    @Value("${app.async.comparison-max-pool-size:8}")
    private int comparisonMaxPoolSize;

    @Value("${app.async.comparison-queue-capacity:25}")
    private int comparisonQueueCapacity;

    @Bean(name = "comparisonTaskExecutor")
    public Executor comparisonTaskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(comparisonCorePoolSize);
        executor.setMaxPoolSize(comparisonMaxPoolSize);
        executor.setQueueCapacity(comparisonQueueCapacity);
        executor.setThreadNamePrefix("FileCompare-");
        executor.setWaitForTasksToCompleteOnShutdown(true);
        executor.setAwaitTerminationSeconds(60);
        executor.initialize();
        return executor;
    }
}
