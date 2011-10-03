class AddressesController < ApplicationController
  before_filter :find_person

  def create
    address = Address.new(params[:address].merge({:person_id => @person.id}))
    if address.save
      flash[:notice] = "Successfully added an address for #{@person.first_name} #{@person.last_name}."
    else
      flash[:error] = "There was a problem creating this address."
    end
    redirect_to person_path(@person)
  end

  def update
    if @person.address.update_attributes(params[:address])
      flash[:notice] = "Successfully updated the address for #{@person.first_name} #{@person.last_name}."
    else
      flash[:error] = "There was a problem updating this address."
    end
    redirect_to person_path(@person)
  end

  def destroy
  end

  private

  def find_person
    @person = AthenaPerson.find(params[:person_id])
  end
end