package gov.cdc.datacompareapis.shared;

import java.io.PrintWriter;
import java.io.StringWriter;

public class StackTraceUtil {
    public static String getStackTraceAsString(Exception e) {
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        e.printStackTrace(printWriter);
        return stringWriter.toString();
    }
}
