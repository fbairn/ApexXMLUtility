public with sharing class XML_Demo {
	public static string AccountToXML(Set<ID> accountID) {
		Dom.Document doc = new Dom.Document();

		Dom.Xmlnode rootNode = doc.createRootElement('response', null, null);

		List<Account> accountList = [SELECT  id, name,
		                             (SELECT id, name, email, phone from Contacts)
		                             FROM  Account
		                             WHERE id IN :accountID];

		for (Account eachAccount : accountList) {
			Dom.Xmlnode accountNode = rootNode.addChildElement('Account', null, null);
			accountNode.setAttribute('id', eachAccount.Id);
			accountNode.setAttribute('name', eachAccount.Name);

			for (Contact eachContact : eachAccount.Contacts) {
				Dom.Xmlnode contactNode = accountNode.addChildElement('Contact', null, null);
				contactNode.setAttribute('id', eachContact.Id);
				if (eachContact.Name != null) {
					contactNode.setAttribute('name', eachContact.Name);
				}
				if (eachContact.Email != null) {
					contactNode.setAttribute('email', eachContact.Email);
				}
				if (eachContact.Phone != null) {
					contactNode.setAttribute('phone', eachContact.Phone);
				}
			}
		}

		return doc.toXmlString();
	}







	public static Map<String, Map<String, Object>> parseResponseDom(String xml) {
		Dom.Document doc = new Dom.Document();
		doc.Load(xml);

		System.debug(loggingLevel.Info, '*** doc: ' + doc);
		//Retrieve the root element for this document.
		Dom.XMLNode response = doc.getRootElement();
		System.debug(loggingLevel.Info, '*** response: ' + response);

		return MapChildNodes(response);
	}

	private static Map<String, Map<String, Object>> MapChildNodes(Dom.XMLNode node) {
		Map<String, Map<String, Object>> nodeMap = new Map<String, Map<String, Object>> ();
		for (Dom.XMLNode childNode : node.getChildren()) {
			Map<String, Map<String, Object>> childMap = new Map<String, Map<String, Object>> ();
			//Attributes
			childMap.put('Attributes', AttributesToMap(childNode));
			
			//Child Nodes
			childMap.put('Children', MapChildNodes(childNode));

			nodeMap.put(childNode.getAttributeValue('name', null), childMap);
		}
		return nodeMap;
	}

	private static Map<String, String> AttributesToMap(Dom.XMLNode node) {
		Map<String, String> attributeList = new  Map<String, String>();
		for (Integer i = 0; i < node.getAttributeCount(); i++) {
			attributeList.put(node.getAttributeKeyAt(i), node.getAttribute(node.getAttributeKeyAt(i), null));
		}
		return attributeList;
	}
}