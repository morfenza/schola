# frozen_string_literal: true

NUMBER_OF_SUBJECTS = 7
NUMBER_OF_TEACHERS = 20
NUMBER_OF_GRADES = [4, 8].freeze

DEFINED_YEAR_RANGE = 2012..2023
DEFINED_GRADE_RANGE = 5..9
DEFINED_STUDENTS_NUM_RANGE = 20..40

CHANCE_OF_RE_ENROLLMENT = 0.70

# Subjects already defined on factory
def create_subjects
  FactoryBot.create_list(:subject, NUMBER_OF_SUBJECTS)
end

def create_teachers
  FactoryBot.create_list(:teacher, NUMBER_OF_TEACHERS)
end

def create_courses
  current_class = nil
  enrolled_students = nil

  DEFINED_YEAR_RANGE.each do |current_year|
    puts "\t\t Year: #{current_year}"
    DEFINED_GRADE_RANGE.each do |current_grade|
      puts "\t\t\t Grade: #{current_grade}"
      current_class = FactoryBot.create(
        :course,
        year: current_year,
        name: "#{current_grade}º Série"
      )

      enrolled_students = if current_year == DEFINED_YEAR_RANGE.first
                            create_new_students
                          else
                            sort_or_create_studends
                          end

      puts "\t\t\t\t Resolving enrollments"
      create_enrollments(enrolled_students, current_class)

      puts "\t\t\t\t Resolving assignments"
      create_teacher_assingments(current_class)

      puts "\t\t\t\t Resolving exams"
      create_exams(current_class)
    end
  end
end

def create_new_students
  number_of_students = rand(DEFINED_STUDENTS_NUM_RANGE)
  enrolled_students = []

  number_of_students.times do
    enrolled_students.append FactoryBot.create(:student)
  end

  enrolled_students
end

def sort_or_create_studends
  number_of_students = rand(DEFINED_STUDENTS_NUM_RANGE)
  enrolled_students = []

  number_of_students.times do
    if rand.truncate(2) <= CHANCE_OF_RE_ENROLLMENT
      enrolled_students.append Student.all.sample
    else
      enrolled_students.append FactoryBot.create(:student)
    end
  end

  enrolled_students
end

def create_enrollments(enrolled_students, current_class)
  until enrolled_students.empty?
    FactoryBot.create(
      :enrollment,
      student: enrolled_students.pop,
      course: current_class
    )
  end
end

def create_teacher_assingments(current_class)
  available_teachers = Teacher.all

  Subject.all.each do |current_subject|
    TeacherAssignment.create!(
      teacher: available_teachers.sample,
      subject: current_subject,
      course: current_class
    )
  end
end

def create_exams(current_class)
  if current_class.year == DEFINED_YEAR_RANGE.last
    # creates four exams per subject
    Subject.all.each do |current_subject|
      4.times do
        current_exam = FactoryBot.create(
          :exam,
          course: current_class,
          subject: current_subject
        )

        create_grades(current_class, current_exam)
      end
    end
  else
    # creates eight exams per subject
    Subject.all.each do |current_subject|
      8.times do
        current_exam = FactoryBot.create(
          :exam,
          course: current_class,
          subject: current_subject
        )

        create_grades(current_class, current_exam)
      end
    end
  end
end

def create_grades(current_class, current_exam)
  current_class.enrollments.each do |current_enrollment|
    Grade.create!(
      value: rand(0.0..10.0),
      enrollment: current_enrollment,
      exam: current_exam
    )
  end
end

puts '#### Seeds Logging ####'
puts "\t Creating subjects....."
create_subjects

puts "\t Creating teachers....."
create_teachers

puts "\t Creating courses......"
create_courses
