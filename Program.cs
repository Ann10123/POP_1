using System;
using System.Threading;
using System.Numerics;

namespace ThreadDemo
{
    class CalculatorTask
    {
        private int _id;
        private int _step;
        private volatile bool _canStop = false; 

        public CalculatorTask(int id, int step)
        {
            _id = id;
            _step = step;
        }

        public void Calculate()
        {
            BigInteger sum = 0;
            BigInteger count = 0;
            BigInteger current = 0; 

            do
            {
                sum += current;
                current += _step;
                count++;
            } while (!_canStop);

            Console.WriteLine($"Потік {_id} завершив роботу: Сума = {sum}, Кількість доданків = {count}");
        }

        public void Stop()
        {
            _canStop = true;
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            Console.OutputEncoding = System.Text.Encoding.UTF8; 
            Console.Write("Введіть кількість потоків: ");
            int input = int.Parse(Console.ReadLine()); 
            new Program().Start(input);
        }

        void Start(int numThreads)
        {
            CalculatorTask[] tasks = new CalculatorTask[numThreads];

            Console.WriteLine("\nГоловний потік: Запуск робочих потоків...");

            for (int i = 0; i < numThreads; i++)
            {
                int threadId = i + 1;
                int step = threadId * 2; 

                tasks[i] = new CalculatorTask(threadId, step);
                
                Thread workerThread = new Thread(tasks[i].Calculate);
                workerThread.Start();
            }

            Thread stopperThread = new Thread(() => Stopper(tasks));
            stopperThread.Start();

            stopperThread.Join();
            
            Console.WriteLine("Головний потік: Усі потоки зупинено, програма завершує роботу.");
        }

        void Stopper(CalculatorTask[] tasks)
        {
            Console.WriteLine("Керуючий потік: Початок зупинки потоків по черзі...\n");
            
            foreach (var task in tasks)
            {
                Thread.Sleep(1000); 
                task.Stop();  
            }
        }
    }
}