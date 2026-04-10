import { Injectable } from '@angular/core';
import { dummyTasks } from '../dummy-tasks';
import { type NewTaskData, type Task } from './task/task.model';

@Injectable({
  providedIn: 'root'
})
export class TasksService {
  private tasks = dummyTasks;
  
  constructor() { 
    const storedTasks = localStorage.getItem('tasks');
    if (storedTasks) {
      this.tasks = JSON.parse(storedTasks);
    }
  }

  getUserTasks(userId: string) {
    return this.tasks.filter(task => task.userId === userId);
  }

  addTask(task: NewTaskData, userId: string) {
    const newTask: Task = {
          id: new Date().getTime().toString(),
          userId: userId,
          title: task.title,
          summary: task.summary,
          dueDate: task.date
        };
        this.tasks.unshift(newTask);
        this.saveTasksToLocalStorage();
  }

  removeTask(taskId: string) {
    this.tasks = this.tasks.filter(task => task.id !== taskId);
    this.saveTasksToLocalStorage();
  }

  private saveTasksToLocalStorage() {
    localStorage.setItem('tasks', JSON.stringify(this.tasks));
  }

}
