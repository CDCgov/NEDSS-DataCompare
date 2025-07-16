package gov.cdc.datacompareapis.configuration;


import gov.cdc.datacompareapis.property.DbPropertiesProvider;
import jakarta.persistence.EntityManagerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.boot.orm.jpa.EntityManagerFactoryBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import javax.sql.DataSource;
import java.util.HashMap;


@Configuration
@EnableTransactionManagement
@EnableJpaRepositories(
        entityManagerFactoryRef = "rdbModernEntityManagerFactory",
        transactionManagerRef = "rdbModernTransactionManager",
        basePackages = {
                "gov.cdc.datacompareapis.repository.rdbModern"
        }
)
public class RdbModernDataSourceConfig {
    private final DbPropertiesProvider dbPropertiesProvider;

    @Value("${spring.datasource.rdbModern.url}")
    private String dbUrl;

    public RdbModernDataSourceConfig(DbPropertiesProvider dbPropertiesProvider) {
        this.dbPropertiesProvider = dbPropertiesProvider;
    }

    @Bean(name = "rdbModernDataSource")
    public DataSource rdbModernDataSource() {
        DataSourceBuilder dataSourceBuilder = DataSourceBuilder.create();

        dataSourceBuilder.driverClassName(dbPropertiesProvider.getDriverClassName());
        dataSourceBuilder.url(dbUrl);
        dataSourceBuilder.username(dbPropertiesProvider.getDbUserName());
        dataSourceBuilder.password(dbPropertiesProvider.getDbUserPassword());

        return dataSourceBuilder.build();
    }

    @Bean(name = "rdbModernEntityManagerFactoryBuilder")
    public EntityManagerFactoryBuilder rdbModernEntityManagerFactoryBuilder() {
        return new EntityManagerFactoryBuilder(new HibernateJpaVendorAdapter(), new HashMap<>(), null);
    }

    @Primary
    @Bean(name = "rdbModernEntityManagerFactory")
    public LocalContainerEntityManagerFactoryBean rdbModernEntityManagerFactory(
            @Qualifier("rdbModernEntityManagerFactoryBuilder") EntityManagerFactoryBuilder builder,
            @Qualifier("rdbModernDataSource") DataSource dataSource) {
        return builder
                .dataSource(dataSource)
                .packages("gov.cdc.datacompareapis.repository.rdbModern.model")
                .persistenceUnit("rdbModern")
                .build();
    }

    @Primary
    @Bean(name = "rdbModernTransactionManager")
    public PlatformTransactionManager rdbModernTransactionManager(
            @Qualifier("rdbModernEntityManagerFactory") EntityManagerFactory entityManagerFactory) {
        return new JpaTransactionManager(entityManagerFactory);
    }


    @Bean(name = "rdbModernJdbcTemplate")
    public JdbcTemplate rdbModernJdbcTemplate(@Qualifier("rdbModernDataSource") DataSource dataSource) {
        return new JdbcTemplate(dataSource);
    }
}
