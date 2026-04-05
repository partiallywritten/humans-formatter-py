def time_formatter(ms: int, should_compound: bool = False, should_round: bool = False) -> str:
    if ms == 0:
        return "0ms"

    SECOND = 1000
    MINUTE = 60 * SECOND
    HOUR = 60 * MINUTE
    DAY = 24 * HOUR

    is_negative = ms < 0
    casted_time = abs(ms)

    result = "-" if is_negative else ""

    if should_compound:
        days = casted_time // DAY
        casted_time -= days * DAY

        hours = casted_time // HOUR
        casted_time -= hours * HOUR

        minutes = casted_time // MINUTE
        casted_time -= minutes * MINUTE

        seconds = casted_time // SECOND

        if days > 0:
            result += f"{days}d {hours}h {minutes}m {seconds}s"
        elif hours > 0:
            result += f"{hours}h {minutes}m {seconds}s"
        elif minutes > 0:
            result += f"{minutes}m {seconds}s"
        elif seconds > 0:
            result += f"{seconds}s"
        else:
            result += f"{casted_time}ms"

    else:
        value = casted_time
        suffix = "ms"
        divisor = 1

        if value >= DAY:
            divisor = DAY
            suffix = "d"
        elif value >= HOUR:
            divisor = HOUR
            suffix = "h"
        elif value >= MINUTE:
            divisor = MINUTE
            suffix = "m"
        elif value >= SECOND:
            divisor = SECOND
            suffix = "s"

        if should_round and divisor > 1:
            value = (casted_time + (divisor // 2)) // divisor
        else:
            value = casted_time // divisor

        result += f"{value}{suffix}"

    return result


def byte_formatter(size: int) -> str:
    if size == 0:
        return "0 B"

    units = ["B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB"]

    is_negative = size < 0
    casted_size = abs(size)
    size_fcast = float(casted_size)

    uindx = 0
    while size_fcast >= 1024.0 and uindx < len(units) - 1:
        size_fcast /= 1024.0
        uindx += 1

    result = "-" if is_negative else ""

    if uindx == 0:
        result += f"{size_fcast:.0f} {units[uindx]}"
    else:
        result += f"{size_fcast:.2f} {units[uindx]}"

    return result
