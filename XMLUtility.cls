public class XMLUtility {
    /**
     * This will take an XML input and return an object.
     * This works the same way as JSON.deserialize
     * @param  xml        XML String to deserialize
     * @param  objectType The Object type to deserialize to (IE: Object.class)
     * @return A generic object that can be cast to the object type.
     */
    public static object deserialize(String xml, System.Type objectType) {
        String jsonString = JSON.serialize(XMLUtility.parseResponseDom(XML));
        return JSON.deserialize(jsonString, objectType);
    }
    
    public static string serialize(Object obj, String rootName){
        Map<string, object> objMap = (Map<string, object>)JSON.deserializeUntyped(JSON.serialize(obj));

        DOM.Document doc = new DOM.Document();
        
        DOM.XmlNode envelope
            = doc.createRootElement(rootName, null, null);
        
        for(string key: objMap.keyset()){
            buildXML(envelope, objMap.get(key), key);
        }
        
        return doc.toXmlString();
    }
    
    private static void buildXMLFromMap(DOM.XmlNode envelope, Map<string, object> objMap){
        for(string key: objMap.keyset()){
            buildXML(envelope, objMap.get(key), key);
        }
    }
    
    private static void buildXMLFromList(DOM.XmlNode envelope, List<object> objList, string name){
        for(object obj: objList){
            buildXML(envelope, obj, name);
        }
    }
    
    private static void buildXML(DOM.XmlNode envelope, Object obj, String name){
        DOM.XmlNode body = envelope.addChildElement(name, null, null);
        if(obj instanceof Map<String, Object>){
            buildXMLFromMap(body, (Map<string, object>)obj);
        } else if (obj instanceof List<Object>){
            buildXMLFromList(body, (List<object>)obj, name);
        } else {
            if(obj!=null){
                String value=String.ValueOf(obj);
                if(name.isAllUpperCase()){
                    envelope.removeChild(body);
                    envelope.setAttribute(name, value);
                } else {
                    body.addTextNode(value);
                }
            }
        }
    }

    private static Map<String, Object> parseResponseDom(String xml) {
        Dom.Document doc = new Dom.Document();
        doc.Load(xml);

        //Retrieve the root element for this document.
        Dom.XMLNode response = doc.getRootElement();

        return MapChildNodes(response);
    }

    private static Map<String, Object> MapChildNodes(Dom.XMLNode node) {
        Map<String, Object> nodeMap = new Map<String, Object> ();
        Set<String> childLists = FindChildLists(node);
        for (Dom.XMLNode childNode : node.getChildren()) {
            Map<String, Object> childMap = new Map<String, Object> ();

            //Attributes
            childMap.putAll(AttributesToMap(childNode));

            //Child Nodes
            if (childNode.getChildren().size() > 0) {
                childMap.putAll(MapChildNodes(childNode));
            }

            AddToMap(childNode, childMap, childLists, nodeMap);
        }
        return nodeMap;
    }

    @testVisible private static void AddToMap(Dom.XMLNode childNode, Map<String, Object> childMap, Set<String> childLists, Map<String, Object> nodeMap) {
        if (String.isNotBlank(childNode.getName())) {
            if (childLists.contains(childNode.getName())) {
                //This is a list item
                List<Map<String, Object>> childL = new List<Map<String, Object>>();
                if (nodeMap.containsKey(childNode.getName())) {
                    childL = (List<Map<String, Object>>)nodeMap.get(childNode.getName());
                }
                childL.add(childMap);
                nodeMap.put(childNode.getName(), childL);
            } else if (childNode.getChildElements().size() == 0) {
                nodeMap.put(childNode.getName(), childNode.getText());
            } else {
                //This is a normal item
                nodeMap.put(childNode.getName(), childMap);
            }
        }
    }

    /**
     * Finds any duplicate child names.
     * These are the childern that are lists.
     **/
    @TestVisible private static Set<String> FindChildLists(Dom.XMLNode node) {
        Set<String> childSet = new Set<String>();
        Set<string> checkedChildern = new Set<string>();
        for (Dom.XMLNode childNode : node.getChildren()) {
            if (checkedChildern.contains(childNode.getName())) {
                childSet.add(childNode.getName());
            }
            checkedChildern.add(childNode.getName());
        }
        return childSet;
    }

    @TestVisible private static Map<String, Object> AttributesToMap(Dom.XMLNode node) {
        Map<String, Object> attributeList = new  Map<String, Object>();
        for (Integer i = 0; i < node.getAttributeCount(); i++) {
            attributeList.put(node.getAttributeKeyAt(i), node.getAttribute(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i)));
            //node.getAttribute(, null)
        }
        return attributeList;
    }
}