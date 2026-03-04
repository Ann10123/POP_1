with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

procedure Main is

   -- об'єкт для прапорця зупинки (безпечний для потоків)
   protected type Stop_Flag is
      procedure Set_True;
      function Is_True return Boolean;
   private
      Value : Boolean := False;
   end Stop_Flag;

   protected body Stop_Flag is
      procedure Set_True is
      begin
         Value := True;
      end Set_True;

      function Is_True return Boolean is
      begin
         return Value;
      end Is_True;
   end Stop_Flag;

   Num_Threads : Integer;

begin
   Put ("Введіть кількість потоків: ");
   Get (Num_Threads);
   
   Put_Line ("");
   Put_Line ("Головний потік: Запуск робочих потоків...");

   declare
      -- масив прапорців (по одному для кожного потоку)
      Flags : array (1 .. Num_Threads) of Stop_Flag;

      -- типи потоків
      task type Calculator_Task is
         entry Start (Task_Id : Integer; Task_Step : Long_Long_Integer);
      end Calculator_Task;

      task type Stopper_Task is
         entry Start;
      end Stopper_Task;

      -- створюємо потоки
      Workers : array (1 .. Num_Threads) of Calculator_Task;
      Stopper : Stopper_Task;

      -- описуємо, що роблять потоки
      task body Calculator_Task is
         Id      : Integer;
         Step    : Long_Long_Integer;
         Sum     : Long_Long_Integer := 0;
         Count   : Long_Long_Integer := 0;
         Current : Long_Long_Integer := 0;
      begin
         -- чекаємо команду на старт із параметрами
         accept Start (Task_Id : Integer; Task_Step : Long_Long_Integer) do
            Id := Task_Id;
            Step := Task_Step;
         end Start;

         -- головний цикл обчислень
         loop
            Sum := Sum + Current;
            Current := Current + Step;
            Count := Count + 1;
            
            -- звертаємося до масиву прапорців за своїм номером
            exit when Flags(Id).Is_True; 
         end loop;

         Put_Line ("Потік " & Integer'Image(Id) & " завершив роботу: Сума =" &
                   Long_Long_Integer'Image(Sum) & ", Кількість доданків =" &
                   Long_Long_Integer'Image(Count));
      end Calculator_Task;

      task body Stopper_Task is
      begin
         -- чекаємо команду на старт
         accept Start; 
         Put_Line ("Керуючий потік: Початок зупинки потоків по черзі...");
         
         for I in 1 .. Num_Threads loop
            delay 1.0; -- чекаємо 
            Flags(I).Set_True; -- зупиняємо конкретний потік
         end loop;
      end Stopper_Task;

   begin
      -- запускаємо робочі потоки, роздаючи їм їхні номери та кроки
      for I in 1 .. Num_Threads loop
         Workers(I).Start (I, Long_Long_Integer(I * 2));
      end loop;
      
      -- коли всі робочі отримали завдання, запускаємо зупиняч
      Stopper.Start;
      
      -- головний потік автоматично зупиняється 
   end;

   Put_Line ("Головний потік: Усі потоки зупинено, програма завершує роботу.");
end Main;
