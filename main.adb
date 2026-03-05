with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;

procedure Main is

   -- об'єкт для прапорця зупинки 
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

   declare
      -- масив прапорців 
      Flags : array (1 .. Num_Threads) of Stop_Flag;

      -- типи потоків
      task type Calculator_Task is
         entry Start (Task_Id : Integer; Task_Step : Long_Long_Integer);
      end Calculator_Task;

      task type Stopper_Task is
         entry Start;
      end Stopper_Task;

      task type Timer_Task is
         entry Start_Timer (Target_ID : Integer; Wait_Time : Duration);
      end Timer_Task;

      -- створюємо потоки
      Workers : array (1 .. Num_Threads) of Calculator_Task;
      Stopper : Stopper_Task;

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

      task body Timer_Task is
         My_Target : Integer;
         My_Delay  : Duration;
      begin
         -- Отримуємо від Стоппера номер потоку і скільки спати
         accept Start_Timer (Target_ID : Integer; Wait_Time : Duration) do
            My_Target := Target_ID;
            My_Delay  := Wait_Time;
         end Start_Timer;
         
         -- Спимо, а потім зупиняємо СВІЙ потік
         delay My_Delay;
         Flags(My_Target).Set_True;
      end Timer_Task;

      task body Stopper_Task is
         Gen : Generator;
         Random_Delay : Float;
         
         Timers : array (1 .. Num_Threads) of Timer_Task;
      begin
         accept Start; 
         Reset(Gen);
         
         for I in 1 .. Num_Threads loop
            -- Генеруємо час від 0.5 до 5.0 секунд
            Random_Delay := Random(Gen) * 4.5 + 0.5; 
            
            -- Миттєво запускаємо таймер для потоку I
            Timers(I).Start_Timer(I, Duration(Random_Delay));
         end loop;
      end Stopper_Task;

   begin
      -- запускаємо робочі потоки, роздаючи їм їхні номери та кроки
      for I in 1 .. Num_Threads loop
         Workers(I).Start (I, Long_Long_Integer(I * 2));
      end loop;
      
      -- запускаємо зупиняч
      Stopper.Start;
   end;
end Main;