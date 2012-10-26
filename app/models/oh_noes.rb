module OhNoes
  module Destroy
    
    def self.included(base)
      base.class_eval do
        default_scope where(:deleted_at => nil)
      end
    end
  
    delegate :destroy!, :to => :destroy
    def destroy
      return false unless destroyable?
      run_callbacks :destroy do
        update_attribute(:deleted_at, Time.now)
      end
    end
    
    def destroyable?
      true
    end
  
  end
end