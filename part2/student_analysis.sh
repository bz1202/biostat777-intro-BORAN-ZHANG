#!/bin/bash
# student_analysis.sh - Shell script for student data processing as required by Part 2.

# Define variables for cleaner code
DOWNLOAD_URL="https://raw.githubusercontent.com/stephaniehicks/jhustatprogramming2025/main/projects/01-project/students.csv"
FILE_NAME="students.csv"

echo "--- PART 2: SHELL SCRIPT ANALYSIS ---"
echo ""

# ---- 1. Download students.csv file using curl ---- #
echo "STEP 1: Downloading $FILE_NAME locally."
# -sL: silent and follow redirects
curl -sL $DOWNLOAD_URL -o $FILE_NAME

if [ $? -ne 0 ]; then
    echo "ERROR: File download failed."
    exit 1
fi
echo "Download successful."
echo ""

# ---- 2. Display the contents of the students.csv file using cat ---- #
echo "STEP 2: Displaying file contents (cat)."
cat $FILE_NAME
echo ""

# ---- 3. Display only the first 5 lines of the file using head ---- #
echo "STEP 3: Displaying first 5 lines (head -n 5)."
head -n 5 $FILE_NAME
echo ""

# ---- 4. Display only the last 3 lines of the file using tail ---- #
echo "STEP 4: Displaying last 3 lines (tail -n 3)."
tail -n 3 $FILE_NAME
echo ""

# ---- 5. Count the number of lines in the file using wc -l ---- #
echo "STEP 5: Counting total number of lines (wc -l)."
wc -l $FILE_NAME
echo ""

# ---- 6. Find all students taking 'Math' as a subject using grep ---- #
echo "STEP 6: Finding students taking 'Math' (grep)."
# Filter out the header line before searching for 'Math'
grep 'Math' $FILE_NAME | grep -v 'Subject'
echo ""

# ---- 7. Find all female students using grep (Gender is column 4, 'F') ---- #
echo "STEP 7: Finding all female students (grep ',F,')."
# Use ',F,' to specifically match the Gender column
grep ',F,' $FILE_NAME
echo ""

# ---- 8. Sort the file by the students' ages in ascending order (Column 3) ---- #
echo "STEP 8: Sorting by Age (Column 3, numeric sort)."
# Print header (head -n 1) then sort data lines (tail -n +2)
(head -n 1 $FILE_NAME && tail -n +2 $FILE_NAME | sort -t ',' -k 3,3n)
echo ""

# ---- 9. Find the unique subjects listed in the file (Column 6) ---- #
echo "STEP 9: Finding unique subjects (cut, sort, uniq)."
# -d ',' specifies comma delimiter; -f 6 extracts the 6th field (Subject)
cut -d ',' -f 6 $FILE_NAME | tail -n +2 | sort | uniq
echo ""

# ---- 10. Calculate the average grade of the students (Column 5) using awk ---- #
echo "STEP 10: Calculating the average grade (awk)."
awk -F ',' '
BEGIN { sum=0; count=0 }
FNR > 1 {
    sum += $5; # $5 is the Grade column
    count++
}
END {
    if (count > 0) {
        printf "Average Grade: %.2f\n", sum/count
    } else {
        print "No student records found."
    }
}' $FILE_NAME
echo ""

# ---- 11. Replace all occurrences of 'Math' with 'Mathematics' using sed ---- #
echo "STEP 11: Replacing 'Math' with 'Mathematics' (sed)."
sed 's/Math/Mathematics/g' $FILE_NAME
echo ""

# ---- 12. Clean up: Remove the temporary downloaded file ---- #
rm $FILE_NAME
echo "CLEANUP: $FILE_NAME file removed."