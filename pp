import json
import os
from datetime import datetime

# ---------- Data Storage ----------
DATA_FILE = "attendance_data.json"

def load_data():
    """Load all data from JSON file."""
    if not os.path.exists(DATA_FILE):
        # Initialize with default data if file doesn't exist
        default_data = {
            "teachers": {
                "teacher1": "pass123",
                "teacher2": "pass456"
            },
            "classes": {
                "CS101": {
                    "name": "Introduction to Programming",
                    "students": [
                        {"id": "S001", "name": "Alice Johnson"},
                        {"id": "S002", "name": "Bob Smith"},
                        {"id": "S003", "name": "Charlie Brown"},
                        {"id": "S004", "name": "Diana Prince"}
                    ],
                    "attendance": []
                },
                "MATH202": {
                    "name": "Calculus II",
                    "students": [
                        {"id": "S005", "name": "Ethan Hunt"},
                        {"id": "S006", "name": "Fiona Gallagher"},
                        {"id": "S007", "name": "George Costanza"},
                        {"id": "S008", "name": "Hannah Baker"}
                    ],
                    "attendance": []
                }
            }
        }
        save_data(default_data)
        return default_data
    with open(DATA_FILE, 'r') as f:
        return json.load(f)

def save_data(data):
    """Save all data to JSON file."""
    with open(DATA_FILE, 'w') as f:
        json.dump(data, f, indent=4)

# ---------- Authentication ----------
def login(teachers):
    """Teacher login authentication."""
    print("\n" + "=" * 50)
    print("        STUDENT ATTENDANCE SYSTEM")
    print("=" * 50)
    print("\n--- Teacher Login ---")
    username = input("Username: ").strip()
    password = input("Password: ").strip()
    
    if username in teachers and teachers[username] == password:
        print(f"\n Login successful! Welcome, {username}.")
        return username
    else:
        print("\n Invalid credentials. Access denied.")
        return None

# ---------- Class Selection ----------
def select_class(classes):
    """Display available classes and let teacher choose one."""
    print("\n--- Available Classes ---")
    class_list = list(classes.keys())
    for idx, class_code in enumerate(class_list, 1):
        print(f"{idx}. {class_code} - {classes[class_code]['name']}")
    
    while True:
        try:
            choice = int(input("\nWhich class are we looking at? (Enter number): "))
            if 1 <= choice <= len(class_list):
                selected_code = class_list[choice - 1]
                print(f"\n Selected: {selected_code} - {classes[selected_code]['name']}")
                return selected_code
            else:
                print(f"Please enter a number between 1 and {len(class_list)}.")
        except ValueError:
            print("Invalid input. Please enter a number.")

# ---------- Mark Attendance ----------
def mark_attendance(class_data, class_code):
    """Display student list and record attendance."""
    students = class_data["students"]
    print(f"\n--- Marking Attendance for {class_code} ---")
    print("Date:", datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    print("\nStudent List:")
    print("-" * 40)
    for idx, student in enumerate(students, 1):
        print(f"{idx}. {student['name']} ({student['id']})")
    
    attendance_record = {
        "date": datetime.now().strftime("%Y-%m-%d"),
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "records": []
    }
    
    print("\n--- Mark Attendance ---")
    print("Enter 'p' for Present, 'a' for Absent, or 'l' for Late")
    print("-" * 40)
    
    for student in students:
        while True:
            status = input(f"{student['name']} ({student['id']}): ").strip().lower()
            if status in ['p', 'a', 'l']:
                status_full = {'p': 'Present', 'a': 'Absent', 'l': 'Late'}[status]
                attendance_record["records"].append({
                    "student_id": student['id'],
                    "student_name": student['name'],
                    "status": status_full
                })
                break
            else:
                print("Invalid input. Please enter 'p', 'a', or 'l'.")
    
    # Add to class attendance history
    class_data["attendance"].append(attendance_record)
    print("\n✅ Attendance saved successfully!")
    return attendance_record

# ---------- Display Summary ----------
def show_attendance_summary(class_data, class_code):
    """Show recent attendance records for the class."""
    if not class_data["attendance"]:
        print(f"\nNo attendance records found for {class_code}.")
        return
    
    print(f"\n--- Recent Attendance Records for {class_code} ---")
    # Show last 5 records (or all if less)
    recent = class_data["attendance"][-5:]
    for record in reversed(recent):
        print(f"\n Date: {record['date']} ({record['timestamp']})")
        print("-" * 30)
        for r in record["records"]:
            status_symbol = "" if r['status'] == 'Present' else "" if r['status'] == 'Absent' else ""
            print(f"  {status_symbol} {r['student_name']}: {r['status']}")
        print("-" * 30)

# ---------- Main Program ----------
def main():
    data = load_data()
    teachers = data["teachers"]
    classes = data["classes"]
    
    # Step 1: Authentication
    teacher = login(teachers)
    if not teacher:
        return
    
    while True:
        print("\n" + "=" * 50)
        print("MAIN MENU")
        print("=" * 50)
        print("1. Mark Attendance")
        print("2. View Attendance Summary")
        print("3. Exit")
        
        choice = input("\nChoose an option (1-3): ").strip()
        
        if choice == '1':
            # Step 2: Select class
            class_code = select_class(classes)
            # Step 3: Display student list and mark attendance (Action)
            mark_attendance(classes[class_code], class_code)
            # Step 4: Save data (Output)
            save_data(data)
        
        elif choice == '2':
            class_code = select_class(classes)
            show_attendance_summary(classes[class_code], class_code)
        
        elif choice == '3':
            print("\n Session ended. Goodbye!")
            break
        
        else:
            print("Invalid choice. Please enter 1, 2, or 3.")

if __name__ == "__main__":
    main()
