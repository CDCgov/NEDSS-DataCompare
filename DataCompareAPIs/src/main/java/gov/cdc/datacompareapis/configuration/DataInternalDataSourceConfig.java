//package gov.cdc.datacompareapis.configuration;
//
//import jakarta.persistence.EntityManagerFactory;
//import org.springframework.beans.factory.annotation.Qualifier;
//import org.springframework.beans.factory.annotation.Value;
//import org.springframework.boot.jdbc.DataSourceBuilder;
//import org.springframework.boot.orm.jpa.EntityManagerFactoryBuilder;
//import org.springframework.context.annotation.Bean;
//import org.springframework.context.annotation.Configuration;
//import org.springframework.context.annotation.Primary;
//import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
//import org.springframework.jdbc.core.JdbcTemplate;
//import org.springframework.orm.jpa.JpaTransactionManager;
//import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
//import org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter;
//import org.springframework.transaction.PlatformTransactionManager;
//import org.springframework.transaction.annotation.EnableTransactionManagement;
//
//import javax.sql.DataSource;
//import java.util.HashMap;
//
//
//@Configuration
//@EnableTransactionManagement
//@EnableJpaRepositories(
//        entityManagerFactoryRef = "dataCompareEntityManagerFactory",
//        transactionManagerRef = "dataCompareTransactionManager",
//        basePackages = {
//                "gov.cdc.datacompareapis.repository.dataCompare"
//        }
//)
//public class DataInternalDataSourceConfig {
//    @Value("${spring.datasource.driverClassName}")
//    private String driverClassName;
//
//    @Value("${spring.datasource.dataCompare.url}")
//    private String dbUrl;
//
//    @Value("${spring.datasource.username}")
//    private String dbUserName;
//
//    @Value("${spring.datasource.password}")
//    private String dbUserPassword;
//
//    @Bean(name = "dataCompareDataSource")
//    public DataSource dataCompareDataSource() {
//        DataSourceBuilder dataSourceBuilder = DataSourceBuilder.create();
//
//        dataSourceBuilder.driverClassName(driverClassName);
//        dataSourceBuilder.url(dbUrl);
//        dataSourceBuilder.username(dbUserName);
//        dataSourceBuilder.password(dbUserPassword);
//
//        return dataSourceBuilder.build();
//    }
//
//    @Bean(name = "dataCompareEntityManagerFactoryBuilder")
//    public EntityManagerFactoryBuilder dataCompareEntityManagerFactoryBuilder() {
//        return new EntityManagerFactoryBuilder(new HibernateJpaVendorAdapter(), new HashMap<>(), null);
//    }
//
//    @Primary
//    @Bean(name = "dataCompareEntityManagerFactory")
//    public LocalContainerEntityManagerFactoryBean dataCompareEntityManagerFactory(
//            @Qualifier("dataCompareEntityManagerFactoryBuilder") EntityManagerFactoryBuilder builder,
//            @Qualifier("dataCompareDataSource") DataSource dataSource) {
//        return builder
//                .dataSource(dataSource)
//                .packages("gov.cdc.datacompareapis.repository.dataCompare.model")
//                .persistenceUnit("dataCompare")
//                .build();
//    }
//
//    @Primary
//    @Bean(name = "dataCompareTransactionManager")
//    public PlatformTransactionManager dataCompareTransactionManager(
//            @Qualifier("dataCompareEntityManagerFactory") EntityManagerFactory entityManagerFactory) {
//        return new JpaTransactionManager(entityManagerFactory);
//    }
//
//
//    @Bean(name = "dataCompareJdbcTemplate")
//    public JdbcTemplate dataCompareJdbcTemplate(@Qualifier("dataCompareDataSource") DataSource dataSource) {
//        return new JdbcTemplate(dataSource);
//    }
//}
