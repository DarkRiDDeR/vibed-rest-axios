module vibed_rest_axios.rest_axios;

import vibe.web.internal.rest.common;
import vibe.web.rest: RestInterfaceSettings;


void genRestAxios (I) (RestInterfaceSettings vibeRestSettings, string dir = "./", string name = null) {
    import std.file: copy;
    import std.stdio: File;

    if (name == null) name = I.stringof;

    string outData = generateInterface!I(vibeRestSettings);
    outData = genMainTemplate!"main.mixin.js"(name, outData);

    // create files
    auto f = File(dir~"/"~name~".js", "w");
    f.write(outData);
    f.close();
}

string generateInterface (I) (RestInterfaceSettings vibeRestSettings)
    if (is(I == interface))
{
    import std.conv : to;
    import std.traits : FunctionTypeOf, ReturnType;

    import vibe.http.common : HTTPMethod;
    import vibe.inet.url: URL;
    import vibe.data.json;
    import vibe.data.serialization: serialize;

    string getFmtParam(ref const PathPart p)
    {
        if (!p.isParameter) return serialize!JsonSerializer(p.text).toString();
        return "toRestString("~p.text~")";
    }

    string outData = "";
    auto vibeIntf = RestInterface!I(vibeRestSettings, true);

    foreach (i, SI; vibeIntf.SubInterfaceTypes) {
        string name = __traits(identifier, vibeIntf.SubInterfaceFunctions[i]);
        if (i != 0) outData ~= ",\n";
        outData ~= "'" ~ name ~ "': { " ~ generateInterface!SI(vibeIntf.subInterfaces[i].settings) ~ " }";
    }
    if (vibeIntf.SubInterfaceTypes.length != 0) outData ~= ",\n";

    foreach (i, F; vibeIntf.RouteFunctions) {
        alias FT = FunctionTypeOf!F;
        auto route = vibeIntf.routes[i];


        string url = "";

        // url assembly
        if (route.pathHasPlaceholders) {
            auto burl = URL(vibeIntf.baseURL);
            if (burl.host.length) {
                // extract the server part of the URL
                burl.pathString = "/";
                url ~= serialize!JsonSerializer((burl.toString()[0 .. $-1])).toString() ~ " + ";
            }
            // and then assemble the full path piece-wise

            // if route.pathHasPlaceholders no need to check route.fullPathParts.length
            // because it fills in module vibe.web.internal.rest.common at 208 line only
            url ~= getFmtParam(route.fullPathParts[0]);
            foreach (p; route.fullPathParts[1..$]) {
                url ~= " + "~ getFmtParam(p);
            }
        } else {
            url = "'"~concatURL(vibeIntf.baseURL, route.pattern)~"'";
        }

        // query parameters
        if (route.queryParameters.length) {
            foreach (j, p; route.queryParameters) {
                url ~= ` + "` ~ (j == 0 ? `?` : `&`) ~ p.fieldName ~ `=" + toRestString(` ~ p.name ~ `)`;
            }
        }

        // body parameters
        string bodyParams = "";
        if (route.wholeBodyParameter.name.length) {
            bodyParams = "'"~route.wholeBodyParameter.name~"'";
        } else if (route.bodyParameters.length) {
            bodyParams = paramsToStr(route.bodyParameters);
        }

        // header parameters
        string headers = "";
        if (route.headerParameters.length > 0) {
            headers = paramsToStr(route.headerParameters);
        }

        string axiosTmpl = genAxiosTemplate!"axios.mixin.js"(url, route.method.to!string, headers, bodyParams);
        string funParams = "";
        foreach (j, p; route.parameters) {
            if (j != 0) funParams ~= ",";
            funParams ~= p.name;
        }
        if (i != 0) outData ~= ",\n";
        outData ~= genMethodTemplate!"method.mixin.js"(route.functionName, funParams, axiosTmpl);
    }

    return outData;
}

string paramsToStr (in Parameter[] params) {
    import vibe.data.json : Json;

    string str = "";
    foreach (j, p; params) {
        if (j != 0) str ~= ", ";
        str ~= Json(p.fieldName).toString()~": "~p.name;
    }
    return "{" ~ str ~ "}";
}

private string genAxiosTemplate (string path)(in string url, in string method, in string headers, in string data)
{
    return mixin("`" ~ import(path) ~ "`");
}

private string genMainTemplate (string path)(in string name, in string obBody)
{
    return mixin("`" ~ import(path) ~ "`");
}

private string genMethodTemplate (string path)(in string name, in string params, in string result)
{
    return mixin("`" ~ import(path) ~ "`");
}


package string concatURL(string prefix, string url, bool trailing = false)
@safe {
    import std.algorithm : startsWith, endsWith;

    auto pre = prefix.endsWith("/");
    auto post = url.startsWith("/");

    if (!url.length) return trailing && !pre ? prefix ~ "/" : prefix;

    auto suffix = trailing && !url.endsWith("/") ? "/" : null;

    if (pre) {
        // "/" is ASCII, so can just slice
        if (post) return prefix ~ url[1 .. $] ~ suffix;
        else return prefix ~ url ~ suffix;
    } else {
        if (post) return prefix ~ url ~ suffix;
        else return prefix ~ "/" ~ url ~ suffix;
    }
}