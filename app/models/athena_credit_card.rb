class AthenaCreditCard < AthenaResource::Base

  self.site = Artfully::Application.config.tickets_site
  self.prefix = '/payments/'
  self.collection_name = 'cards'
  self.element_name = 'cards'

  schema do
    attribute 'cardholder_name',        :string
    attribute 'card_number',            :string
    attribute 'expiration_date',        :string
    attribute 'cvv',                   :string

    attribute 'customer', :string
  end

  validates_presence_of :expiration_date, :cardholder_name

  validates_presence_of       :card_number, :if => Proc.new { |card| card.new_record? }
  validates_numericality_of   :card_number, :if => Proc.new { |card| card.new_record? }
  validate                    :valid_luhn,  :if => Proc.new { |card| card.new_record? }

  validates_presence_of     :cvv, :if => Proc.new { |card| card.new_record? }
  validates_numericality_of :cvv, :if => Proc.new { |card| card.new_record? }
  validates_length_of       :cvv, :in => 3..4, :if => Proc.new { |card| card.new_record? }


  def valid_luhn
    errors.add(:card_number, "This doesn't look like a valid credit card.") unless passes_luhn?(card_number)
  end

  def passes_luhn?(num)
    odd = true
    num.to_s.gsub(/\D/,'').reverse.split('').map(&:to_i).collect { |d|
      d *= 2 if odd = !odd
      d > 9 ? d - 9 : d
    }.sum % 10 == 0
  end

  def initialize(attributes = {})
    prepare_attr!(attributes) if needs_date_parse(attributes)
    super
  end

  def update_attributes(attributes)
    prepare_attr!(attributes)
    super
  end

  def encode(options = {})
    if !new_record?
      if options[:rejections].nil? 
        options[:rejections] = []
      end
      options[:rejections] << 'card_number'
    end
    super(prepare_for_encode(@attributes), options)
  end

  private
    def needs_date_parse(attrs = {})
      attrs.has_key? 'expiration_date(3i)' or attrs['expiration_date'].is_a? String
    end

    def prepare_attr!(attributes)
      #TODO: Debt; need to refector how we juggle the expirationDate as it uses a mm/yyyy format.
      unless attributes.blank?
        if attributes.has_key?('expiration_date(3i)')
          day = attributes.delete('expiration_date(3i)')
          month = attributes.delete('expiration_date(2i)')
          year = attributes.delete('expiration_date(1i)')
          attributes['expiration_date'] = Date.parse("#{year}-#{month}-#{day}")
        else
          attributes['expiration_date'] = Date.parse(attributes['expiration_date'])
        end
      end
    end

    def prepare_for_encode(attributes)
      hash = attributes.dup
      attributes['expiration_date'] = Date.parse(self.expiration_date) if self.expiration_date.is_a? String
      hash['expiration_date'] = self.expiration_date.strftime('%m/%Y')
      hash
    end
end
