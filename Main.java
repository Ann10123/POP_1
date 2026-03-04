import java.util.Scanner;
import java.math.BigInteger;

public class Main {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);  
        
        System.out.print("Введіть кількість потоків: ");
        int input = scanner.nextInt(); 
        new Main().startApp(input);
        scanner.close(); 
    }

    void startApp(int numThreads) {
        CalculatorTask[] tasks = new CalculatorTask[numThreads];
        Thread[] workers = new Thread[numThreads];
        System.out.println("\nГоловний потік: Запуск робочих потоків...");

        for (int i = 0; i < numThreads; i++) {
            int threadId = i + 1;
            int step = threadId * 2; 

            tasks[i] = new CalculatorTask(threadId, step);
            
            Thread workerThread = new Thread(tasks[i]);
            workers[i] = workerThread;
            workerThread.start();
        }

        Thread stopperThread = new Thread(() -> stopper(tasks));
        stopperThread.start();

        try {
            stopperThread.join();
            for (Thread worker : workers) {
                worker.join(); 
            }
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        
        System.out.println("Головний потік: Усі потоки зупинено, програма завершує роботу.");
    }

    void stopper(CalculatorTask[] tasks) {
        System.out.println("Керуючий потік: Початок зупинки потоків по черзі...\n");
        
        for (CalculatorTask task : tasks) {
            try {
                Thread.sleep(500); 
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            task.stopTask();       
        }
    }
}

class CalculatorTask implements Runnable {
    private int id;
    private int step;
    private volatile boolean canStop = false; 

    public CalculatorTask(int id, int step) {
        this.id = id;
        this.step = step;
    }

    @Override
    public void run() {
        BigInteger sum = BigInteger.ZERO;
        long count = 0;
        long current = 0; 

        do {
            sum = sum.add(BigInteger.valueOf(current));
            current += step; 
            count++;
        } while (!canStop);

        System.out.println("Потік " + id + " завершив роботу: Сума = " + sum + ", Кількість доданків = " + count);
    }

    public void stopTask() {
        canStop = true;
    }
}