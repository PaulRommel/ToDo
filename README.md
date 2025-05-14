<img src="https://github.com/PaulRommel/ToDo/blob/main/demo/me.gif" width="250" height="350"/>

# ToDo List Application

## Overview
A Swift-based iOS task management app built with VIPER architecture, Core Data persistence, and REST API integration.

## Features

### Core Functionality
✅ Create, read, update, delete tasks  
✅ Mark tasks as complete/incomplete  
✅ Detailed task viewing  
✅ Search and filter tasks  

### Technical Highlights
🛠 VIPER architecture  
💾 Core Data persistence  
🌐 DummyJSON API integration  
🔄 Pull-to-refresh  
📱 Context menus (iOS 13+)  

## Modules Structure

## Key Components

### TaskList Module
- **View**: `TaskListViewController`
  - UITableView with custom cells
  - UISearchController
  - Context menus

- **Presenter**: `TaskListPresenter`
  - Handles business logic
  - Mediates View-Interactor communication

- **Interactor**: `TaskListInteractor`
  - Manages Core Data operations
  - Handles API communication
  - Implements search functionality

- **Router**: `TaskListRouter`
  - Navigation to detail screen
  - Module creation

### TaskCell
- Custom design with:
  - Title label
  - Description label
  - Date label  
  - Checkmark button
- Dynamic styling for completed tasks

## Data Flow
1. **Initialization**:
   ```mermaid
   graph TD
   A[First Launch] --> B[Load from API]
   A --> C[Save to Core Data]
   D[Subsequent Launches] --> E[Load from Core Data]

graph LR
View-->|User Action|Presenter
Presenter-->|Request|Interactor
Interactor-->|Update|CoreData
Interactor-->|Response|Presenter
Presenter-->|Update|View

# 📝 ToDo List Application - Полное описание функционала

## 📌 Основные возможности

### 1. Управление задачами
- **Добавление задач**
  - Заголовок (обязательно)
  - Описание (опционально)
  - Автоматическое сохранение даты создания
- **Редактирование**
  - Изменение текста задачи
  - Обновление описания
- **Удаление задач**
  - Через свайп или контекстное меню
  - Подтверждение действия

### 2. Отметка выполнения
- ✅ Одним нажатием на чекбокс
- 📅 Автоматическое сохранение даты завершения
- ~~Сквозное подчеркивание~~ для выполненных задач
- Визуальное отличие (серый цвет выполненных)

## 🔍 Поиск и фильтрация
- 🔎 Поиск по:
  - Заголовку
  - Описанию
- 🕵️‍♂️ Инкрементальный поиск (результаты обновляются при вводе)
- ❌ Кнопка отмены поиска

## 📱 Пользовательский интерфейс
### Главный экран
- 📋 Список задач с сортировкой по дате (новые сверху)
- ✏️ Контекстное меню на долгом нажатии:
  - Редактировать
  - Удалить
- 🔄 Pull-to-refresh для обновления списка

### Экран деталей
- 🖼️ Отображение полной информации:
  - Заголовок (крупный шрифт)
  - Полное описание
  - Дата создания
  - Статус выполнения
  - Дата завершения (если выполнено)

## ⚙️ Технические особенности
### Работа с данными
- 💾 Локальное хранение (Core Data)
- 🌐 Первоначальная загрузка тестовых данных с API (dummyjson.com)
- 🔄 Автоматическая синхронизация изменений

### Архитектура
- 🏗 VIPER (View-Interactor-Presenter-Entity-Router)
- 🧩 Модульная структура
- ↔️ Четкое разделение ответственности

## 🛠 Дополнительные функции
- 📤 Шеринг задач (текстовый формат)
- 🎨 Кастомизация ячеек:
  - Адаптивная высота
  - Разные стили для выполненных/активных задач
- 📅 Форматирование дат (месяц/день/год + время)

## 🔄 Жизненный цикл задач
1. Создание → 2. Редактирование → 3. Выполнение → 4. Удаление  
*(Возможен возврат на любом этапе)*

## 📊 Особенности отображения
```mermaid
graph TD
    A[Новая задача] -->|Пользователь вводит| B[Сохранение]
    B --> C[Отображение в списке]
    C -->|Нажатие| D[Детальный просмотр]
    C -->|Свайп| E[Удаление]
    C -->|Чекбокс| F[Отметка выполнения]
