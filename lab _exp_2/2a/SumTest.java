public class SumTest {
    public static void main(String[] args) {
        long startTime = System.currentTimeMillis();
        long sum = 0;
        long max = 1000000000L; // 1 billion iterations

        for (long i = 1; i <= max; i++) {
            sum += i;
        }

        long endTime = System.currentTimeMillis();
        double duration = (endTime - startTime) / 1000.0;

        System.out.println("Sum Result: " + sum);
        System.out.println("Execution Time: " + duration + " seconds");
    }
}
