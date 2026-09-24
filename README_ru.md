<a id="readme"></a>
# ReDrive
> **ReDrive** — это open-source приложение для работы с OBD2-адаптерами, которое позволяет вам подключаться к автомобилю через Bluetooth, Wi-Fi или USB, читать данные с датчиков, диагностировать ошибки и многое другое.
<div align="center">
  <img src="docs/app.png" alt="ReDrive App" width="100%" />
</div>
<br>
<p align="center">  
<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />  
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />  
<img src="https://img.shields.io/badge/OBD2-ELM327-orange?style=for-the-badge" alt="OBD2 ELM327" />  
<a href="https://github.com/iUnreallx/ReDrive/issues">
  <img src="https://img.shields.io/github/issues/iUnreallx/ReDrive?style=for-the-badge" alt="Open Issues" />
</a>
<img src="https://img.shields.io/badge/License-GPLv3-blue?style=for-the-badge" alt="GPLv3 License" />
<img src="https://img.shields.io/badge/Contributions-Welcome-brightgreen?style=for-the-badge" alt="Contributions Welcome" />  
</p>
<p align="center">
  <a href="README.md">
    <img src="https://img.shields.io/badge/Language-English-blue?style=for-the-badge" alt="English" />
  </a>
  <a href="README_ru.md">
    <img src="https://img.shields.io/badge/Язык-Русский-red?style=for-the-badge" alt="Русский" />
  </a>
</p>

<details>
  <summary>Оглавление</summary>
  <ol>
    <li>
      <a href="#о-проекте">О проекте</a>
      <ul>
        <li><a href="#спроектирован-с-помощью">Спроектирован с помощью</a></li>
      </ul>
    </li>
    <li><a href="#интерфейс-приложения">Интерфейс приложения</a></li>
    <li><a href="#почему-redrive">Почему ReDrive?</a></li>
    <li><a href="#поддерживаемые-адаптеры">Поддерживаемые адаптеры</a></li>
    <li><a href="#установка-и-запуск">Установка и запуск</a></li>
    <li><a href="#структура-репозитория">Структура репозитория</a></li>
    <li><a href="#как-использовать">Как использовать?</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#лицензия-license">Лицензия</a></li>
    <li><a href="#контакты">Контакты</a></li>
  </ol>
</details>


## О проекте
**ReDrive** создан для тех, кто хочет иметь полный контроль над своим автомобилем через современный, быстрый и удобный интерфейс. Приложение в реальном времени считывает телеметрию с ЭБУ (ECU), переводит её в читаемый вид и позволяет проводить базовую диагностику.

**Ключевые возможности:**
*   **Чтение и сброс ошибок (DTC):** Сканирование кодов неисправностей (Check Engine) с их детальной расшифровкой и возможностью очистки.
*   **Real-time мониторинг (Live Data):** Отслеживание оборотов, скорости, температуры охлаждающей жидкости, напряжения и десятков других параметров без задержек.
*   **Современный дашборд:** Настраиваемая приборная панель с чистым UI, которая не отвлекает от дороги.
*   **Стабильное подключение:** Поддержка различных протоколов связи и автоматическое восстановление соединения таких как Bluetooth, Wi-Fi, USB.

## Спроектирован с помощью

* [![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
* [![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)

## Интерфейс приложения
<div style="display: flex; justify-content: center; gap: 10px;">
  <img src="docs/screenshots/1.png" width="49%" />
  <img src="docs/screenshots/2.png?v=2" width="49%" />
</div>

## Почему ReDrive?
Рынок OBD2-приложений переполнен устаревшими решениями, перегруженными рекламой, сложными интерфейсами или скрытыми подписками.

Мы создаем альтернативу, опираясь на три принципа:
1.  **Open-Source:** Полностью открытый исходный код. Вы можете проверить безопасность, форкнуть проект или помочь в его развитии.
2.  **UI/UX в приоритете:** Никакого визуального мусора. Только те данные, которые нужны вам прямо сейчас, в приятном дизайне.
3.  **Бесплатно и без рекламы:** Весь диагностический функционал доступен "из коробки" без пейволлов.

## Поддерживаемые адаптеры
Приложение работает с большинством популярных диагностических сканеров:
*   Любые **ELM327**-совместимые адаптеры (Bluetooth, Wi-Fi, USB).
*   *Рекомендуются адаптеры версии v1.5 (на чипах PIC18F25K80) для максимальной совместимости со всеми протоколами автомобилей.*

## Установка и запуск

Для сборки проекта вам потребуется установленный [Flutter SDK](https://docs.flutter.dev/get-started/install).

1. Клонируем репозиторий
```sh
git clone [https://github.com/iUnreallx/ReDrive.git](https://github.com/iUnreallx/ReDrive.git)
```

2. Переходим в директорию
```sh
cd ReDrive
```

3. Устанавливаем зависимости
```sh
flutter pub get
```

4. Запускаем проект на подключенном устройстве
```sh
flutter run
```


## Структура репозитория

```text
ReDrive/
├── android/                         # Платформа Android
├── ios/                             # Платформа iOS
├── assets/                          # Изображения, иконки и шрифты
├── docs/                            # Сайт, дорожная карта и скриншоты
├── lib/                             # Исходный код Flutter
│   ├── main.dart                    # Точка входа и регистрация провайдеров
│   ├── core/                        # Цвета и темы
│   ├── obd/                         # OBD-II ядро, независимое от транспорта
│   │   ├── connection/             # Интерфейс OBD-транспорта
│   │   ├── demo/                   # Генератор демонстрационных данных
│   │   ├── elm/                    # Команды, очередь, клиент и парсер ELM327
│   │   ├── models/                 # Модель телеметрии автомобиля
│   │   ├── pid/                    # Реестр, определения и декодеры PID
│   │   ├── polling/                # Списки наблюдения и опрос PID
│   │   ├── session/                # Инициализация сессии ELM327
│   │   └── source/                 # Источник данных OBD и его состояния
│   ├── providers/                   # Состояние Bluetooth и OBD для приложения
│   ├── screens/                     # Главный экран, подключение, автомобиль, настройки и навигация
│   ├── services/bluetooth/          # Соединение Bluetooth, устройства и разрешения
│   └── widget/                      # Переиспользуемые компоненты интерфейса
│       ├── bottom_bar/              # Нижняя навигация
│       ├── connection/              # Виджеты экрана подключения
│       ├── home_screen/             # Виджеты главного экрана
│       └── reconnection_banner.dart # Баннер состояния переподключения
├── test/                            # Тесты OBD-слоёв и провайдеров
│   ├── obd/
│   └── providers/
├── pubspec.yaml                     # Зависимости и ресурсы Flutter
├── README.md                        # Описание проекта на английском
├── README_ru.md                     # Описание проекта на русском
└── LICENSE                          # Лицензия проекта
```

## Как использовать?

1. Подключите OBD2-адаптер (ELM327) в диагностический порт автомобиля.
2. Включите зажигание или заведите двигатель.
3. Сопрягите смартфон с адаптером (Bluetooth/Wi-Fi/USB).
4. Откройте **ReDrive**, перейдите в раздел подключения и выберите ваш адаптер.
5. Так же можно использовать наш эмулятор для тестов: https://github.com/iUnreallx/ELM327-Emulator

## Roadmap 

Подробный план развития, текущие задачи и будущие функции описаны в отдельном документе:
* [Посмотреть Roadmap](docs/roadmap/roadmap_ru.md)

## Contributing

Вклады сообщества делают open-source лучше. Ваши предложения и пул-реквесты приветствуются.

1. Сделайте Fork репозитория.
2. Создайте ветку (`git checkout -b feature/AmazingFeature`).
3. Закоммитьте изменения (`git commit -m 'Add some AmazingFeature'`).
4. Запушьте ветку (`git push origin feature/AmazingFeature`).
5. Откройте Pull Request.

### Лучшие контрибьютеры:


<p>
  <a href="https://github.com/iUnreallx/ReDrive/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=iUnreallx/ReDrive" />
  </a>
</p>

## Лицензия (License)

Проект распространяется по лицензии GNU GPLv3. Подробности в файле [LICENSE](LICENSE).

## Контакты

GitHub: [@iUnreallx](https://github.com/iUnreallx) <br>
Ссылка на проект: [https://github.com/iUnreallx/ReDrive](https://github.com/iUnreallx/ReDrive)<br>
Telegram: [Unreallx](https://t.me/unreallx)
<p align="right">(<a href="#readme">наверх</a>)</p>
