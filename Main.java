import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Random;
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
    }

    void stopper(CalculatorTask[] tasks) {
        Random rnd = new Random();
        
        for (int i = 0; i < tasks.length; i++) {
            int randomSleep = rnd.nextInt(4500) + 500; 
            final CalculatorTask currentTask = tasks[i]; 
            new Thread(() -> {
                try {
                    Thread.sleep(randomSleep); 
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                currentTask.stopTask(); 
            }).start();
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
