require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :products
  
  test "product attributes must not be empty" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:image_url].any?
    assert product.errors[:price].any?
  end
  
  test "product price must be >= 0.01" do
    product = Product.new(:title => "My book title",
                          :description => "My book description",
                          :image_url => "images/my_image.jpg")
    product.price = -1
    assert product.invalid?
    assert_equal "must be greater than or equal to 0.01",
      product.errors[:price].join('; ')

    product.price = 0
    assert product.invalid?
    assert_equal "must be greater than or equal to 0.01",
      product.errors[:price].join('; ')
    
    product.price = 1
    assert product.valid?
    
    product.price = 0.01
    assert product.valid?
  end
  
  def new_product(image_url)
    Product.new(:title => "My book title",
                :description => "My book description",
                :price => 1,
                :image_url => image_url)
  end
  
  test "image url is valid" do
    ok = %w{ fred.gif fred.jpg fred.png FRED.JPG FRED.Jpg
              http://www.test.com/images/Fred.giF }
    bad = %w{ fred.doc fred.gif/more fred.gif.more }
    
    ok.each do |name|
      assert new_product(name).valid?, "#name shouldn't be invalid"
    end
    
    bad.each do |name|
      assert new_product(name).invalid?, "#name shouldn't be valid"
    end
  end
  
  test "product must have a unique title" do
    product = Product.new(:title => products(:ruby).title,
                          :description => "My book description",
                          :price => 1,
                          :image_url => "images/my_image.jpg")
    
    assert !product.save
    assert_equal I18n.translate('activerecord.errors.messages.taken'),
                 product.errors[:title].join('; ')
  end
end
