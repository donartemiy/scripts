# -u или nounset: Сгенерировать ошибку и прекратить выполнение, если переменная не была объявлена, но используется в какой-то команде. 
# -e или errexit: Сгенерировать ошибку и прекратить выполнение, если команда в скрипте завершается с ненулевым статусом (ошибка).
set -ue
 
show_help() {
  echo "Использование: script.sh [опции]"
  echo "Опции:"
  echo "  --host              Показать информацию о хосте"
  echo "  --user              Показать информацию о пользователях"
  echo "  -h, --help          Показать help"
}

get_cpu_cores() {
    cores=$(grep -c '^processor' /proc/cpuinfo)
      echo "Количество ядер: $cores"
}

get_memory_info() {
    local meminfo
    meminfo=$(cat /proc/meminfo)
    total_memory=$(echo "$meminfo" | grep -i "MemTotal" | awk '{print $2}')
    free_memory=$(echo "$meminfo" | grep -i "MemFree" | awk '{print $2}')
    used_memory=$((total_memory - free_memory))

    # Переводим значения памяти в гигабайты
    total_memory=$(bc <<< "scale=2; $total_memory / 1024^2")    # scale=2; округление 
    free_memory=$(bc <<< "scale=2; $free_memory / 1024^2")
    used_memory=$(bc <<< "scale=2; $used_memory / 1024^2")

    echo "Оперативная память: всего: $total_memory Gb / использовано: $used_memory Gb / свободно: $free_memory Gb"
}

get_disk_info() {
  # Получаем список дисков
  disks=$(lsblk -l | awk '/ part \// {print $1}')
  
  # Проходимся по каждому диску
  for disk in $disks
  do
    echo "Раздел: $disk"
      
    # Получаем размер диска
    size=$(lsblk -b -o SIZE -n -d /dev/$disk)
    echo "Размер: $(bc <<< "scale=2; $size / 1024^3") GB"
    
    # Получаем свободное пространство на диске в процентах
    free_space=$(df -h | grep "/dev/$disk" | awk '{print $5}')
    echo "Свободно: $free_space"
    
    echo "-------------------"
  done
}

get_la_info(){
  load_avg=$(awk '{printf("%s %s %s\n",$1,$2,$3)}' < /proc/loadavg)
  echo "Средняя загрузка системы: $load_avg"
}

get_time_info(){  
  current_time=$(date +"%T %Z")
  echo "Текущее время: $current_time"
}

get_uptime_info(){  
  # Читаем информацию из файла /proc/uptime
  uptime_info=$(cat /proc/uptime)

  # Разделяем информацию на две части: время работы и время бездействия
  uptime=$(echo $uptime_info | awk -F '.' '{print $1}')
   idle_time=$(echo $uptime_info | awk '{print $2}')

  # Преобразуем время работы в удобочитаемый формат
  days=$((uptime / 86400))
  hours=$((uptime % 86400 / 3600))
  minutes=$((uptime % 3600 / 60))
  seconds=$((uptime % 60))

  # Выводим время работы системы
  echo "Время работы системы: $days дней, $hours часов, $minutes минут, $seconds секунд"

  echo
}

get_network_info(){
  # Получаем список сетевых интерфейсов
  interfaces=$(ip link show | awk -F': ' '/^[0-9]+:/{print $2}')

  # Проходимся по каждому интерфейсу
  for interface in $interfaces; do
      # Получаем статус интерфейса
      status=$(ip link show "$interface" | grep "state" | awk '{print $9}')

      # Получаем IP-адрес интерфейса
      readarray -t ip_address < <(ip addr show "$interface" | awk '/inet6? /{print $2}')
      
      # Получаем количество отправленных и полученных пакетов
      tx_packets=$(ip -s link show "$interface" | awk '/TX: bytes/{getline; print $2}')
      rx_packets=$(ip -s link show "$interface" | awk '/RX: bytes/{getline; print $2}')

      tx_errors=$(ip -s link show "$interface" | awk '/TX: bytes/{getline; print $3}')
      rx_errors=$(ip -s link show "$interface" | awk '/RX: bytes/{getline; print $3}')

      echo "Interface: $interface"
      echo "Status: $status"
      
      local ipa
      for ipa in "${ip_address[@]}"
      do
        echo "IP Address: $ipa"
      done

      echo "Packets Sent: $tx_packets"
      echo "Errors Sent: $tx_errors"
      echo "Packets Received: $rx_packets"
      echo "Errors Received: $rx_errors"
      echo "-------------------" 
  done
}

get_ports_info(){
    netstat -tuln | grep "LISTEN" 
}

get_host_statistics() {
  echo "=================="
  echo "Статистика о хосте"
  echo "=================="

  echo

  # количество ядер CPU

  get_cpu_cores
  echo
  
  # объём оперативной памяти в системе/ количество использованной оперативной памяти/ количество свободной оперативной памяти

  get_memory_info
  echo

  #  информацию о дисках: какие диски есть в системе, их размер/ сколько свободно на диске (в процентах)/ количество ошибок;
  echo "Информация о дисках:"
  echo "-------------------" 
  get_disk_info
  echo

  # средняя загрузка системы (load average)
  get_la_info
  echo
 
  # текущее время в системе
  get_time_info
  echo

  # время работы системы (uptime) 
  get_uptime_info
  echo

  # сетевые интерфейсы: какие есть в системе, их статус, IP-адрес, количество отправленных и полученных пакетов, количество ошибок на интерфейсе;
  echo "Сетевые интерфейсы:"
  echo "-------------------" 
  get_network_info
  echo

  # порты, которые слушаются на системе
  echo "Слушающие порты:"
  echo "-------------------" 
  get_ports_info
}

get_user_statistics() {
  echo "=========================="
  echo "Статистика о пользователях"
  echo "=========================="


  echo 

  echo "Список пользователей в системе:"
  cat /etc/passwd | awk -F':' '{print "  " $1}'
  
  echo
  
  echo "Список root-пользователей в системе:"
  cat /etc/passwd | awk -F':' '{if ($3 == 0) print $1}'
  
  echo
  
  echo "Список залогиненных пользователей в момент запуска скрипта:"
  who | awk '{print $1}'
}

# Проверка, что скрипт запущен с правами root (иначе не все команды могут корректно отрабатывать)
if [[ $EUID -ne 0 ]]; then
  echo "Ошибка: Скрипт должен быть запущен с правами sudo"
  exit 1
fi

# Проверка наличия bc
if ! which bc >/dev/null 2>&1; then
  echo "Ошибка: возможно, bc не установлен. Проверьте его наличие."
  exit 1
fi

# Объявление ключей и вывод help, если не передали значения
if ! OPTIONS=$(getopt -o "h" -l "help,host,user" -- "$@")
then
  show_help
  exit 1
fi

# Парсинг аргументов
eval set -- "$OPTIONS"

# Обработка аргументов
while true; do
  case "$1" in
    -h|--help)
      show_help
      exit 0 ;;
    --host)
      get_host_statistics
      shift ;;
    --user)
      get_user_statistics
      shift ;;
    --)
      shift
      break ;;
    *)
      echo "Неправильный аргумент"
      show_help
      exit 1 ;;
  esac
done 
