SELECT p.title
    , p.firstname
    , p. middlename
    , p. lastname
    , p.suffix
    , p.emailpromotion
    , at.name AS addresstype
    , a.addressline1
    , a.addressline2
    , a.city
    , sp.stateprovincecode
    , sp.name AS stateprovicename
    , cr.name AS countryregionname
    , a.postalcode
    , ea.emailaddress
    , pnt.name AS phonenumbertype
    , pp.phonenumber
FROM person.person AS p
    INNER JOIN person.businessentityaddress AS bea
        ON p.businessentityid = bea.businessentityid
    INNER JOIN person.address AS a
        ON a.addressid = bea.addressid
    INNER JOIN person.addresstype AS at
        ON at.addresstypeid = bea.addresstypeid
    INNER JOIN person.stateprovince AS sp
        ON sp.stateprovinceid = a.stateprovinceid
    INNER JOIN person.countryregion AS cr
        ON cr.countryregioncode = sp.countryregioncode
    INNER JOIN person.emailaddress AS ea
        ON ea.businessentityid = p.businessentityid
    INNER JOIN person.personphone AS pp
        ON pp.businessentityid = p.businessentityid
    INNER JOIN person.phonenumbertype AS pnt
        ON pnt.phonenumbertypeid = pp.phonenumbertypeid
    ORDER BY lastname, firstname, middlename;