# frozen_string_literal: true

NUMBER_OF_SUBJECTS = 7
NUMBER_OF_TEACHERS = 20

EXAMS_ON_CURRENT_YEAR = 4
EXAMS_PER_YEAR = 8

COURSE_YEAR_RANGE = 2012..Time.current.year
AVAILABLE_GRADES_RANGE = 5..9
STUDENTS_NUM_RANGE = 20..40

CHANCE_OF_RE_ENROLLMENT = 0.70

# Subjects already defined on factory
def create_subjects
  FactoryBot.create_list(:subject, NUMBER_OF_SUBJECTS)
end

def create_teachers
  FactoryBot.create_list(:teacher, NUMBER_OF_TEACHERS)
end

def create_courses
  COURSE_YEAR_RANGE.each do |current_year|
    puts "\t\t Year: #{current_year}"
    AVAILABLE_GRADES_RANGE.each do |current_grade|
      puts "\t\t\t Grade: #{current_grade}"
      current_class = FactoryBot.create(
        :course,
        year: current_year,
        name: "#{current_grade}º Série"
      )

      enrolled_students = if current_year == COURSE_YEAR_RANGE.first
                            create_new_students
                          else
                            sort_or_create_studends
                          end

      puts "\t\t\t\t Resolving enrollments"
      create_enrollments(enrolled_students, current_class)

      puts "\t\t\t\t Resolving assignments"
      create_teacher_assignments(current_class)
    end
  end
end

def create_new_students
  number_of_students = rand(STUDENTS_NUM_RANGE)
  number_of_students.times.collect { FactoryBot.create(:student) }
end

def sort_or_create_studends
  number_of_students = rand(STUDENTS_NUM_RANGE)
  available_students_array = Student.all

  number_of_students.times.collect do
    if rand.truncate(2) <= CHANCE_OF_RE_ENROLLMENT
      available_students_array.sample
    else
      FactoryBot.create(:student)
    end
  end
end

def create_enrollments(enrolled_students, current_class)
  enrolled_students.each do |student|
    FactoryBot.create(
      :enrollment,
      student:,
      course: current_class
    )
  end
end

def create_teacher_assignments(current_class)
  available_teachers = Teacher.all

  Subject.all.each do |current_subject|
    TeacherAssignment.create!(
      teacher: available_teachers.sample,
      subject: current_subject,
      course: current_class
    )
  end
end

def create_all_exams
  all_exams = []

  Course.find_each do |current_course|
    number_of_exams = current_course.year == COURSE_YEAR_RANGE.last ? EXAMS_ON_CURRENT_YEAR : EXAMS_PER_YEAR

    Subject.find_each do |current_subject|
      number_of_exams.times do
        all_exams.append(
          {
            course_id: current_course.id,
            subject_id: current_subject.id,
            realized_on: rand(current_course&.starts_on..current_course&.ends_on)
          }
        )
      end
    end
  end

  Exam.insert_all(all_exams)
end

def create_all_grades
  all_grades = []

  Exam.includes(course: :enrollments).find_each do |current_exam|
    current_exam.course.enrollments.find_each do |current_enrollment|
      all_grades.append(
        {
          value: rand(0.0..10.0).truncate(2),
          exam_id: current_exam.id,
          enrollment_code: current_enrollment.code
        }
      )
    end
  end

  Grade.insert_all(all_grades)
end

puts '#### Seeds Logging ####'
puts "\t Creating subjects....."
create_subjects

puts "\t Creating teachers....."
create_teachers

puts "\t Creating courses......"
create_courses

puts "\t Creating exams........"
create_all_exams

puts "\t Creating grades......."
create_all_grades
