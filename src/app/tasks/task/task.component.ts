import { Component, Input } from '@angular/core';
import { DatePipe } from '@angular/common';
import { Task } from './task.model';

@Component({
  selector: 'app-task',
  standalone: true,
  imports: [DatePipe],
  templateUrl: './task.component.html',
  styleUrl: './task.component.css',
})
export class TaskComponent {
  @Input( { required: true }) task!: Task;
}
