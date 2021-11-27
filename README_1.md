# devops-netology

## 3.5. Файловые системы - Михаил Караханов

**1. Узнайте о sparse (разряженных) файлах.**
- Прочитал статью на вики. Это файлы, при записи которых на диск, последовательности нулевых байтов не записываются на диск, а информация о них записывается в метаданные файловой системы.
  
**2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?**
- Ответ: Hardlink, в отличии от Symlink, имеет один и тот же номер inode, что и исходный файл. Это упоминание одного и того же файла в файловой системе - соответственно, наследуются все права и владельцы данного файла.
  
**3. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим... Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.**
- Результат: выполнено.
  
**4. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.**
- Ответ: выполнено. Результат:
  ```
  vagrant@vagrant:~$ sudo fdisk -l /dev/sdb
  Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
  Disk model: VBOX HARDDISK   
  Units: sectors of 1 * 512 = 512 bytes
  Sector size (logical/physical): 512 bytes / 512 bytes
  I/O size (minimum/optimal): 512 bytes / 512 bytes
  Disklabel type: gpt
  Disk identifier: 5381C9A8-E591-7D47-9163-897F959B927A

  Device       Start     End Sectors  Size Type
  /dev/sdb1     2048 4196351 4194304    2G Linux filesystem
  /dev/sdb2  4196352 5242846 1046495  511M Linux filesystem
  ```

**5. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.**
- Ответ: выполнил команду `sfdisk -d /dev/sdb | sfdisk /dev/sdc `. Результат - аналогичная таблица разделов, как и на `/dev/sdb`:
  ```
  Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
  Disk model: VBOX HARDDISK   
  Units: sectors of 1 * 512 = 512 bytes
  Sector size (logical/physical): 512 bytes / 512 bytes
  I/O size (minimum/optimal): 512 bytes / 512 bytes
  Disklabel type: gpt
  Disk identifier: 5381C9A8-E591-7D47-9163-897F959B927A

  Device       Start     End Sectors  Size Type
  /dev/sdc1     2048 4196351 4194304    2G Linux filesystem
  /dev/sdc2  4196352 5242846 1046495  511M Linux filesystem
  ```
