class PeopleImport < Import
  def kind
    "people"
  end
  
  def rollback 
    self.people.destroy_all
  end
  
  def process(parsed_row)
    person      = create_person(parsed_row)
  end
  
  def row_valid?(parsed_row)
    person = attach_person(parsed_row)
    return (person.valid? ? true : error(parsed_row, person))
  end
  
  def error(parsed_row, person)
    message = ""
    message = parsed_row.email + ": " unless parsed_row.email.blank?
    message = message + person.errors.full_messages.join(", ")    
    raise Import::RowError, message
  end
  
  def create_person(parsed_row)
    Rails.logger.debug("PEOPLE_IMPORT: Importing person")
    person = attach_person(parsed_row)
    Rails.logger.debug("PEOPLE_IMPORT: Attached #{person.inspect}")
    if !person.save
      Rails.logger.debug("PEOPLE_IMPORT: Save failed")
      Rails.logger.debug("PEOPLE_IMPORT: ERROR'D #{person.errors.full_messages.join(", ")}")
      error(parsed_row, person)
    end 
    person  
  end
end