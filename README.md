# devops-netology

## 2.4. Инструменты Git - Михаил Караханов
**1. Найдите полный хеш и комментарий коммита, хеш которого начинается на `aefea`.**
- Выполнил поиск командой `git log -1 --oneline --no-abbrev aefea`.
- Результат: \
`aefead2207ef7e2aa5dc81a34aedf0cad4c32545 Update CHANGELOG.md`

**2. Какому тегу соответствует коммит `85024d3`?**
- Выполнил поиск командой `git show --oneline 85024d3`
- Результат: `tag: v0.12.23`

**3.Сколько родителей у коммита `b8d720`? Напишите их хеши.**
- Для поиска родителей сначала посмотрел на информацию о самом \
целевом коммите командой `git show b8d720`. В комментарии к коммиту \
указано, что это merge-коммит: `Merge pull request #23916 from hashicorp/cgriggs01-stable`. \
Также в выводе указаны краткие хэши родительских коммитов: `Merge: 56cd7859e 9ea88f22f`
- Для получения полного хэша первого "родителя" выполнил команду `git show b8d720^`. \
Результат: `commit 56cd7859e05c36c06b56d013b55a252d0bb7e158`
- Для получения полного хэша второго "родителя" выполнил команду `git show b8d720^2`. \
Результат: `commit 9ea88f22fc6269854151c571162c5bcf958bee2b`.

**4. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами `v0.12.23` и `v0.12.24`.**
- Выполнил поиск командой `git log --oneline --no-abbrev v0.12.24`
- Результат: \
`b14b74c4939dcab573326f4e3ee2a62e23e12f89 [Website] vmc provider links` \
`3f235065b9347a758efadc92295b540ee0a5e26e Update CHANGELOG.md` \
`6ae64e247b332925b872447e9ce869657281c2bf registry: Fix panic when server is unreachable` \
`5c619ca1baf2e21a155fcdb4c264cc9e24a2a353 website: Remove links to the getting started guide's old location` \
`06275647e2b53d97d4f0a19a0fec11f6d69820b5 Update CHANGELOG.md` \
`d5f9411f5108260320064349b757f55c09bc4b80 command: Fix bug when using terraform login on Windows` \
`4b6d06cc5dcb78af637bbb19c198faff37a066ed Update CHANGELOG.md` \
`dd01a35078f040ca984cdd349f18d0b67e486c35 Update CHANGELOG.md` \
`225466bc3e5f35baa5d07197bbc079345b77525e Cleanup after v0.12.23 release`

**5. Найдите коммит в котором была создана функция `func providerSource`, ее определение в коде выглядит так `func providerSource(...)` (вместо троеточего перечислены аргументы).**
- Сначала выяснил в каком конкретно файле определена данная функция командой `git grep "func providerSource"`. Имя файла - `provider_source.go`.
- Далее выполнил поиск коммита, в котором впервые появлялось определение данной функции в конкретном файле, командой `git log -L :'func providerSource':provider_source.go`. \
Результат: коммит с хешем `8c928e83589d90a031f811fae52a81be7153e82f`.

**6. Найдите все коммиты в которых была изменена функция `globalPluginDirs`.**
- Выполнил команду `git log -SglobalPluginDirs --oneline`.
- Результат: \
`35a058fb3 main: configure credentials from the CLI config file` \
`c0b176109 prevent log output during init` \
`8364383c3 Push plugin discovery down into command package`

**7. Кто автор функции `synchronizedWriters`?**
- Команда `git grep 'synchronizedWriters'` не дала результата (значит, в текущих файлах репозитория данная строка не встречается)
- Выполнил команду `git log -S synchronizedWriters --oneline`
- Выбрал самый ранний коммит и выполнил команду для получения информации об авторе коммита `git log -1 --pretty=format:'%an - %ae' 5ac311e2a`.
- Результат: `Martin Atkins - mart@degeneration.co.uk`