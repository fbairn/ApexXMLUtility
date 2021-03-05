@istest public class XMLUtilityTest {
    @istest public static void ParseXML_test() {
        Test.startTest();
        MenuWrapper houseOfFood = (MenuWrapper)XMLUtility.deserialize(XMLString, MenuWrapper.class);
        Test.stopTest();
        System.debug(houseOfFood);
        System.assertEquals(2, houseOfFood.food.size());
        System.assertEquals('Belgian Waffles', houseOfFood.food[0].name);
        System.assertEquals(1, houseOfFood.food[0].id);
        System.assertEquals('Breakfast', houseOfFood.menuName);
    }

    @istest public static void FindChildLists_test() {
        Dom.Document doc = new Dom.Document();
        doc.Load(XMLString);

        //Retrieve the root element for this document.
        Dom.XMLNode response = doc.getRootElement();

        Test.startTest();
        Set<String> results = XMLUtility.FindChildLists(response);
        Test.stopTest();
    }

    @istest public static void AttributesToMap_test() {
        Dom.Document doc = new Dom.Document();
        doc.Load(XMLString);

        //Retrieve the root element for this document.
        Dom.XMLNode response = doc.getRootElement();
        Test.startTest();
        Map<String, Object> results = XMLUtility.AttributesToMap(response.getChildElements()[1]);
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Result should only contain 1 List node.');
    }

    public class MenuWrapper {
        public string menuName;
        public List<FoodWrapper> food;
    }

    public class FoodWrapper {
        public integer id;
        public String name;
    }

    private static string XMLString {
        get{
            return '<breakfast_menu>' +
            '<menuName>Breakfast</menuName>' +
            '<food id="1">' +
            '<name>Belgian Waffles</name>' +
            '<price>$5.95</price>' +
            '<description>' +
            'Two of our famous Belgian Waffles with plenty of real maple syrup' +
            '</description>' +
            '<calories>650</calories>' +
            '</food>' +
            '<food id="2">' +
            '<name>Strawberry Belgian Waffles</name>' +
            '<price>$7.95</price>' +
            '<description>' +
            'Light Belgian waffles covered with strawberries and whipped cream' +
            '</description>' +
            '<calories>900</calories>' +
            '</food>' +
            '</breakfast_menu>';
        }
    }
}