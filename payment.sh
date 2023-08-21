component=payment
source common.sh
rabbitmq_app_password =$1
if [ -z "${rabbitmq_app_password}" ]; then
  echo Input RabbitMQ AppUser password Missing
  exit 1
  fi
func_python



#(roboshop123 is the password)

