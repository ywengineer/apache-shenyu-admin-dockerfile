# Soul Admin docker

[Soul](https://github.com/dromara/soul) admin dockerfile

## Enviroment Vars

| Name           | Type          | Description                    | Default Value |
| -------------- | ------------- | ------------------------------ | ------------- |
| USE_CMS        | Enum('y','n') | use CMS garbage collector      | n             |
| JVM_XMS        | String        | JVM arg -Xms                   | 1g            |
| JVM_XMX        | String        | JVM arg -Xmx                   | 1g            |
| JVM_XMN        | String        | JVM arg -Xmn                   | 512m          |
| JVM_MS         | String        | JVM arg -XX:MetaspaceSize      | 128m          |
| JVM_MMS        | String        | JVM arg -XX:MaxMetaspaceSize   | 128m          |
| JVM_DEBUG      | Enum('y','n') | JVM arg -Xdebug                | n             |
| JMX_ENABLE     | Enum('y','n') | enable JMX                     | n             |
| JMX_HOST       | String        | JMX listen host when enabled   | 0.0.0.0       |
| TIME_ZONE      | String        | system timezone                | Asia/Shanghai |
| LISTEN_PORT    | Integer       | soul listen port               | 9095          |
| MYSQL_HOST     | String        | MySQL database host            | localhost     |
| MYSQL_PORT     | Integer       | MySQL database listen port     | 3306          |
| MYSQL_DB       | String        | MySQL database name            | soul          |
| MYSQL_USER     | String        | MySQL database user            | root          |
| MYSQL_PASSWORD | String        | MySQL database user's password | root          |

## docker-compose.yml
