package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"time"
)

func main() {
	reader := bufio.NewReader(os.Stdin)
	fmt.Print("Enter start date (YYYY-MM-DD): ")
	startStr, _ := reader.ReadString('\n')
	fmt.Print("Enter end date (YYYY-MM-DD): ")
	endStr, _ := reader.ReadString('\n')

	startStr = startStr[:len(startStr)-1]
	endStr = endStr[:len(endStr)-1]

	const layout = "2006-01-02"
	start, err := time.Parse(layout, startStr)
	if err != nil {
		fmt.Println("Invalid start date:", err)
		return
	}
	end, err := time.Parse(layout, endStr)
	if err != nil {
		fmt.Println("Invalid end date:", err)
		return
	}

	for d := start; !d.After(end); d = d.AddDate(0, 0, 1) {
		dateStr := d.Format(layout)
		fmt.Printf("Running: billing-cli iiq --date %s\n", dateStr)

		// dev@daaa85f39c2e:/src$ docker compose run --rm billing-cli iiq --date 2025-08-06
		// [+] Creating 1/1
		//  ✔ Container ggs-mysql-1  Running                                                                                                                0.0s
		// [+] Running 1/1
		//  ✔ Container ggs-dev-init-1  Started                                                                                                             0.2s
		// 2025/08/19 19:23:43 INFO Starting ProcessIIQDeductions reportKey=reports/vr/report_20250805.csv
		// 2025/08/19 19:23:44 INFO Number of updates to be inserted count=5
		// 2025/08/19 19:23:44 INFO Finished ProcessIIQDeductions date=2025-08-19T19:23:44.291Z
		// dev@daaa85f39c2e:/src$

		cmd := exec.Command("docker", "compose", "run", "--rm", "billing-cli", "iiq", "--date", dateStr)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			fmt.Printf("Error running for date %s: %v\n", dateStr, err)
		}
	}
}
