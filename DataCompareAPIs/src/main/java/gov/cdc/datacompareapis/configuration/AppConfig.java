package gov.cdc.datacompareapis.configuration;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.task.SimpleAsyncTaskExecutor;
import org.springframework.scheduling.annotation.EnableAsync;

import java.util.concurrent.Executor;

@Configuration
@EnableAsync
public class AppConfig {

    @Bean(name = "defaultAsyncExecutor")
    public Executor defaultAsyncExecutor() {
        return new SimpleAsyncTaskExecutor(); // Default single-threaded executor
    }
}