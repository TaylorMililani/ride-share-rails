require "test_helper"

describe DriversController do
  # Note: If any of these tests have names that conflict with either the requirements or your team's decisions, feel empowered to change the test names. For example, if a given test name says "responds with 404" but your team's decision is to respond with redirect, please change the test name.
  before do
    @driver = Driver.create(name: "Driver 123", vin: "WBWSS52P9NEYLVDE9", available: true, isactive: true)
  end

  describe "index" do
    it "responds with success when there are many drivers saved" do
      # Arrange
      # Ensure that there is at least one Driver saved
      driver = @driver

      # Act
      get "/drivers"
      
      # Assert
      expect(Driver.count).must_be :>=, 1
      must_respond_with :success
    end

    it "responds with success when there are no drivers saved" do
      # Arrange
      Driver.delete_all
      
      # Ensure that there are zero drivers saved
      # Act
      get "/drivers"

      # Assert
      expect(Driver.count).must_equal 0
      must_respond_with :success
    end
  end

  describe "show" do
    it "responds with success when showing an existing valid driver" do
      # Arrange
      # Ensure that there is a driver saved
      valid_driver_id = @driver.id

      # Act
      get "/drivers/#{ valid_driver_id }"

      # Assert
      must_respond_with :success
    end

    it "responds with 404 with an invalid driver id" do
      # Arrange
      # Ensure that there is an id that points to no driver
      invalid_driver_id = -1

      # Act 
      get "/drivers/#{ invalid_driver_id }"
      
      # Assert
      must_respond_with :not_found
    end

    it "responds with 404 with an inactive driver id" do
      # Arrange
      # Ensure that there is an id that points to inactive driver
      @driver.update(available: false, isactive: false)
      inactive_driver_id = @driver.id

      # Act 
      get "/drivers/#{ inactive_driver_id }"
      
      # Assert
      must_respond_with :not_found
    end
  end

  describe "new" do
    it "can get the new_driver_path" do
      get new_driver_path

      must_respond_with :success
    end

    it "responds with success" do
      get new_driver_path(Driver.first.id)

      must_respond_with :success
    end
  end

  describe "create" do
    let (:valid_driver) { 
      { 
        driver: {
          name: "Create 123", 
          vin: "WBWSS52P9NEYLVDE9", 
          available: true
        }
      }    
    }

    let (:invalid_driver_name) { 
      { 
        driver: {
          name: nil, 
          vin: "WBWSS52P9NEYLVDE9", 
          available: true
        }
      }    
    }

    let (:invalid_driver_vin) { 
      { 
        driver: {
          name: "TEST123", 
          vin: "WBWSS52P9NEY", 
          available: true
        }
      }    
    }

    it "can create a new driver with valid information accurately, and redirect" do
      # Arrange
      # Set up the form data
      # Act-Assert
      # Ensure that there is a change of 1 in Driver.count
      expect {
        post drivers_path, params: valid_driver
      }.must_differ 'Driver.count', 1

      # Assert
      # Find the newly created Driver, and check that all its attributes match what was given in the form data
      expect(Driver.last.name).must_equal valid_driver[:driver][:name]
      expect(Driver.last.vin).must_equal valid_driver[:driver][:vin]
      expect(Driver.last.available).must_equal valid_driver[:driver][:available]

      # Check that the controller redirected the user
      must_respond_with :redirect
      must_redirect_to driver_path(Driver.last.id)
    end

    it "does not create a driver if the form data violates Driver validations - name, and responds with a redirect" do
      # Note: This will not pass until ActiveRecord Validations lesson
      # Arrange
      # Set up the form data so that it violates Driver validations

      # Act-Assert
      # Ensure that there is no change in Driver.count
      expect {
        post drivers_path, params: invalid_driver_name
      }.must_differ 'Driver.count', 0

      # Assert
      # Check that the controller redirects
      must_respond_with :bad_request
    end

    it "does not create a driver if the form data violates Driver validations - VIN, and responds with a redirect" do
      # Act-Assert
      expect {
        post drivers_path, params: invalid_driver_vin
      }.must_differ 'Driver.count', 0

      # Assert
      must_respond_with :bad_request
    end
  end
  
  describe "edit" do
    it "responds with success when getting the edit page for an existing, valid driver" do
      # Arrange
      # Ensure there is an existing driver saved
      valid_driver_id = @driver.id

      # Act
      get edit_driver_path(valid_driver_id)

      # Assert
      must_respond_with :success
    end

    it "responds with redirect when getting the edit page for a non-existing driver" do
      # Arrange
      # Ensure there is an invalid id that points to no driver
      # Act
      get edit_driver_path(-1)

      # Assert
      must_redirect_to drivers_path
    end

    it "responds with 404 when getting the edit page for an inactive driver" do
      # Arrange
      @driver.update(available: false, isactive: false)
      inactive_driver_id = @driver.id

      # Act
      get edit_driver_path(inactive_driver_id)

      # Assert
      must_respond_with :not_found
    end
  end

  describe "update" do
    let (:valid_driver) { 
      { 
        driver: {
          name: "TEST123456TEST", 
          vin: "WBWSS52P9NEYLVDE9", 
          available: true
        }
      }    
    }

    let (:invalid_driver_name) { 
      { 
        driver: {
          name: nil, 
          vin: "WBWSS52P9NEYLVDE9", 
          available: true
        }
      }    
    }

    let (:invalid_driver_vin) { 
      { 
        driver: {
          name: "TEST123456TEST", 
          vin: "WBWSS52P9NEY", 
          available: true
        }
      }    
    }

    it "can update an existing driver with valid information accurately, and redirect" do
      # Arrange
      # Ensure there is an existing driver saved
      # Assign the existing driver's id to a local variable
      # Set up the form data
      id = @driver.id

      # Act-Assert
      # Ensure that there is no change in Driver.count
      expect {
        patch driver_path(id), params: valid_driver
      }.wont_change 'Driver.count'

      # Assert
      # Use the local variable of an existing driver's id to find the driver again, and check that its attributes are updated
      update_driver = Driver.find_by(id: id)
      expect(update_driver.name).must_equal valid_driver[:driver][:name]
      expect(update_driver.vin).must_equal valid_driver[:driver][:vin]
      expect(update_driver.available).must_equal valid_driver[:driver][:available]

      # Check that the controller redirected the user
      must_redirect_to driver_path(id)
    end

    it "does not update any driver if given an invalid id, and responds with a 404" do
      # Arrange
      # Ensure there is an invalid id that points to no driver
      # Set up the form data
      id = -1

      # Act-Assert
      # Ensure that there is no change in Driver.count
      expect {
        patch driver_path(id), params: valid_driver
      }.wont_change 'Driver.count'

      # Assert
      # Check that the controller gave back a 404
      must_respond_with :not_found
    end

    it "does not update any driver if given an inactive driver id, and responds with a 404" do
      # Arrange
      # Ensure there is an invalid id that points to inactive driver
      @driver.update(available: false, isactive: false)
      inactive_driver_id = @driver.id

      # Act-Assert
      # Ensure that there is no change in Driver.count
      expect {
        patch driver_path(inactive_driver_id), params: valid_driver
      }.wont_change 'Driver.count'

      # Assert
      # Check that the controller gave back a 404
      must_respond_with :not_found
    end

    it "does not update a driver if the form data violates Driver validations - name, and responds with a redirect" do
      # Note: This will not pass until ActiveRecord Validations lesson
      # Arrange
      # Ensure there is an existing driver saved
      # Assign the existing driver's id to a local variable
      # Set up the form data so that it violates Driver validations
      id = @driver.id
      
      # Act-Assert
      # Ensure that there is no change in Driver.count
      expect {
        patch driver_path(id), params: invalid_driver_name
      }.must_differ 'Driver.count', 0

      # Assert
      # Check that the controller redirects
      must_respond_with :bad_request
    end

    it "does not update a driver if the form data violates Driver validations - vin, and responds with a redirect" do
      # Arrange
      id = @driver.id

      # Act-Assert
      expect {
        patch driver_path(id), params: invalid_driver_vin
      }.must_differ 'Driver.count', 0

      # Assert
      must_respond_with :bad_request
    end
  end

  describe "destroy" do
    it "inactivates the driver instance in db when driver exists, then redirects" do
      # Arrange
      # Ensure there is an existing driver saved
      valid_driver_id = @driver.id

      # Act-Assert
      # Ensure that there is no change of in Driver.count, but inactivate the driver and turn driver's available to false
      expect {
        delete driver_path(valid_driver_id)
      }.wont_change "Driver.count"
      
      @driver.reload
      expect(@driver.available).must_equal false
      expect(@driver.isactive).must_equal false

      # Assert
      # Check that the controller redirects
      must_redirect_to drivers_path
    end

    it "does not change the db when the driver does not exist, then responds with 404" do
      # Arrange
      # Ensure there is an invalid id that points to no driver
      id = -1

      # Act-Assert
      # Ensure that there is no change in Driver.count
      expect {
        delete driver_path(id)
      }.wont_change "Driver.count"

      # Assert
      # Check that the controller responds or redirects with whatever your group decides
      must_respond_with :not_found
    end

    it "does not change the db when the driver is inactive, then responds with 404" do
      # Arrange
      # Ensure there is an invalid id that points to inactive driver
      @driver.update(available: false, isactive: false)
      inactive_driver_id = @driver.id

      # Act-Assert
      # Ensure that there is no change in Driver.count
      expect {
        delete driver_path(inactive_driver_id)
      }.wont_change "Driver.count"

      # Assert
      # Check that the controller responds or redirects with whatever your group decides
      must_respond_with :not_found
    end
  end
end
