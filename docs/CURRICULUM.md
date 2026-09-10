# Security Curriculum: 1 hour a day

A 12-week path from zero to a full mock engagement, offense and defense together.
Every task runs against the machines in this lab and nothing else.
Five sessions a week, one hour each; the sixth and seventh days are for catching up or resting.

How to use this:
- Start each session by reading the day's objective, then spend the hour doing the task.
- Save output, screenshots and short notes into `loot/` under a folder named for the week.
- If an hour runs out mid-task, stop and finish it the next day. Depth beats speed.
- A day marked (defense) makes you the defender of the same attack you ran as attacker.

Legend: [O] offensive, [D] defensive, [F] foundations.

---

## Week 1 — Foundations and the lab itself [F]

- Day 1: Read the lab `README.md`. Draw the topology from memory. Write down why Metasploitable has no internet.
- Day 2: Boot the BlackArch attacker. Learn the desktop, open a terminal, run `ip a`, identify which NIC is the isolated `seclab` one.
- Day 3: `sudo pacman -Syu` inside the attacker, then install `nmap`, `wireshark-qt`, `tcpdump`. Confirm each runs.
- Day 4: Linux CLI drills: `ls cd cat grep find less man ssh scp`. Practice SSH into Metasploitable (`ssh msfadmin@172.31.66.10`).
- Day 5: Networking basics: IP, subnet, port, TCP vs UDP, the three-way handshake. Watch one handshake in Wireshark.

## Week 2 — Reconnaissance [O]

- Day 1: Host discovery. `nmap -sn 172.31.66.0/24`. Find every live host on the isolated net. Save the list.
- Day 2: Port scanning. `nmap -sS -p- 172.31.66.10`. Note every open port on Metasploitable.
- Day 3: Service and version detection. `nmap -sV -sC 172.31.66.10`. Build a table of service, port, version.
- Day 4: OS detection and timing. `nmap -O -T4`. Learn what `-T0..5` change and why loud scans get caught.
- Day 5: Web recon. Point `nmap --script http-enum` and `whatweb` at the DVWA and Juice Shop URLs. Record findings.

## Week 3 — Enumeration [O]

- Day 1: SMB. `enum4linux 172.31.66.10` and `smbclient -L`. List shares and users you can see.
- Day 2: FTP and Telnet. Connect anonymously, read banners, note the cleartext logins.
- Day 3: Web content discovery. `gobuster dir -u http://192.168.122.1:8081 -w <wordlist>`. Find hidden paths.
- Day 4: Databases. Find the open MySQL/PostgreSQL on Metasploitable, try default creds, list databases.
- Day 5: Write your first recon report in `loot/`: every host, port, service, version, and a guess at the weakest one.

## Week 4 — Web offense: injection [O]

- Day 1: DVWA setup at security level "low". Understand each vulnerability page.
- Day 2: SQL injection by hand on DVWA. Extract the user table. Understand `' OR '1'='1`.
- Day 3: `sqlmap -u <dvwa-url> --cookie=...`. Dump the same table automatically. Compare with by-hand.
- Day 4: Command injection on DVWA. Chain `; id` and read `/etc/passwd`. Understand why input reaches a shell.
- Day 5: Raise DVWA to "medium" then "high". Re-exploit. Learn what each filter blocks and how you bypass it.

## Week 5 — Web offense: the modern app [O]

- Day 1: Juice Shop. Find the score board. Solve two trivial challenges. Learn the browser dev tools.
- Day 2: Cross-site scripting (XSS): reflected, stored, DOM. Land an `alert(1)` in each on Juice Shop.
- Day 3: Broken authentication. Log in as another user. Understand JWT and weak password reset.
- Day 4: WebGoat lessons on access control and insecure deserialization. Work three lessons end to end.
- Day 5: Map today's findings to the OWASP Top 10. Name which category each bug you found belongs to.

## Week 6 — Network exploitation and Metasploit [O]

- Day 1: Install Metasploit in the attacker. `msfconsole`, `db_status`, `workspace`. Import your nmap XML.
- Day 2: Search and read an exploit module. Exploit the vsftpd 2.3.4 backdoor on Metasploitable. Get a shell.
- Day 3: Exploit Samba (usermap_script) or the distccd flaw. Get a second shell a different way.
- Day 4: Payloads and Meterpreter. Get a Meterpreter session, run `sysinfo`, `getuid`, browse the filesystem.
- Day 5: Password attacks. `hydra` against the SSH or FTP service with a small wordlist. Crack `msfadmin`.

## Week 7 — Post-exploitation [O]

- Day 1: Local enumeration on the shell: users, sudo rights, cron jobs, SUID binaries, kernel version.
- Day 2: Privilege escalation to root using one finding from Day 1. Document the exact path.
- Day 3: Loot: find and copy password hashes (`/etc/shadow`). Crack them with `john` or `hashcat`.
- Day 4: Persistence and cleanup concepts. Understand what an attacker leaves behind and why.
- Day 5: Write the offensive half of your engagement report: how you got in, how you became root.

## Week 8 — Defense: seeing the traffic [D]

- Day 1: On the attacker, `tcpdump -i <seclab-nic> -w scan.pcap` while you re-run an nmap scan. Save the capture.
- Day 2: Open `scan.pcap` in Wireshark. Find the scan. See what a SYN scan looks like on the wire.
- Day 3: Capture an exploit from Week 6 to pcap. Find the payload bytes in the stream. This is a detection.
- Day 4: Capture cleartext FTP/Telnet logins. Read the password out of the packets. Understand why TLS matters.
- Day 5: Write filters: a Wireshark display filter that isolates the scan, and one that isolates the exploit.

## Week 9 — Defense: detection and hardening [D]

- Day 1: Install Suricata in the attacker (or a small VM). Run it over `scan.pcap`. Read the alerts it fires.
- Day 2: Write one custom Suricata rule that catches your command-injection payload. Prove it alerts.
- Day 3: Log analysis. On Metasploitable, read `/var/log/auth.log` after your hydra run. Spot the brute force.
- Day 4: Harden a service. Turn off anonymous FTP or Telnet on Metasploitable. Re-scan and confirm it is gone.
- Day 5: Harden the web app. Fix one DVWA vulnerability in code (source is on disk). Re-exploit and watch it fail.

## Week 10 — Red vs blue, round one [O + D]

- Day 1: Pick one attack you know cold. Run it while capturing to pcap and watching logs.
- Day 2: Write the detection: the exact log line or Suricata alert that proves the attack happened.
- Day 3: Attack again with one evasion (slower timing, encoding). See if your detection still fires.
- Day 4: Improve the detection until it catches the evasive version too.
- Day 5: Write it up: attack, artifact left behind, detection rule, and how to harden against it.

## Week 11 — Threat modeling and reporting [D + F]

- Day 1: Threat-model the web victim. List assets, entry points, and the three most likely attacks.
- Day 2: Rank every vulnerability you found across the lab by severity. Justify each rating.
- Day 3: Write remediation for the top five: the specific fix, not "patch it".
- Day 4: Learn CVSS. Score three of your findings. Understand base vs environmental score.
- Day 5: Turn your notes into a clean findings report with an executive summary a non-engineer could read.

## Week 12 — Capstone [O + D]

- Day 1: Reset the lab. Treat Metasploitable and the web apps as an unknown target. Start recon from scratch.
- Day 2: Full attack chain: recon to root, and app compromise, capturing evidence at every step.
- Day 3: Full defensive pass: detections for each step, and a hardening change for each finding.
- Day 4: Write the complete engagement report: scope, method, findings, evidence, remediation.
- Day 5: Plan what is next (see below). Pick your next platform and set a goal.

---

## Where to go after week 12

- Free guided practice: TryHackMe beginner paths, then HackTheBox Academy.
- Retired HackTheBox machines with walkthroughs, to practice on varied targets.
- Add harder victims to this lab: Metasploitable3, VulnHub images, a Windows evaluation VM on the isolated net.
- Certifications, if you want them: CompTIA Security+ for defense, then PNPT or OSCP for offense.
- Capture the Flag events for breadth and speed.

## Habits that matter more than tools

- Take notes as you go, in `loot/`. A finding you cannot reproduce did not happen.
- Understand every command before you run it. `whatweb` and `sqlmap` are tools, not knowledge.
- Always know your scope. In this lab it is the lab. In the real world it is a signed contract.
- For every attack you learn, learn how to see it and how to stop it. That is what makes you employable.
