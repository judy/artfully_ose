class AthenaSection < AthenaResource::Base
  self.site = Artfully::Application.config.stage_site
  self.element_name = 'sections'
  self.collection_name = 'sections'

  schema do
    attribute 'id', :integer
    attribute 'name', :string
    attribute 'capacity', :integer
    attribute 'price', :integer
    attribute 'chart_id', :string
  end

  validates_presence_of :name, :capacity, :price
  validates_numericality_of :capacity, :price

  def chart
    @chart ||= AthenaChart.find(chart_id)
  end

  def chart=(chart)
    raise TypeError, "Expecting an AthenaChart" unless chart.kind_of? AthenaChart
    @chart, self.chart_id = chart, chart.id
  end

  def dup!
    AthenaSection.new(self.attributes.reject { |key, value| key == 'id' })
  end
end